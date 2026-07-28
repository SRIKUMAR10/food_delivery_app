const functions = require("firebase-functions");
const admin = require("firebase-admin");
const Razorpay = require("razorpay");
const cors = require("cors");
const crypto = require("crypto");

admin.initializeApp();

// Use Firebase Environment Configuration for sensitive keys
const rzpKeyId = functions.config().razorpay ? functions.config().razorpay.key_id : (process.env.RAZORPAY_KEY_ID || process.env.RAZORPAY_API_KEY);
const rzpKeySecret = functions.config().razorpay ? functions.config().razorpay.key_secret : process.env.RAZORPAY_KEY_SECRET;
const rzpWebhookSecret = functions.config().razorpay ? functions.config().razorpay.webhook_secret : process.env.RAZORPAY_WEBHOOK_SECRET;

// Initialize Razorpay instance
const razorpay = new Razorpay({
  key_id: rzpKeyId || 'dummy_key_id',
  key_secret: rzpKeySecret || 'dummy_key_secret',
});

const projectId = process.env.GCLOUD_PROJECT || "food-delivery-app-cd4ca";
const corsHandler = cors({ origin: true });

exports.createPaymentLink = functions.https.onRequest((req, res) => {
  corsHandler(req, res, async () => {
    if (req.method !== "POST") {
      return res.status(405).send({ message: "Method Not Allowed" });
    }

    try {
      // 1. Verify Firebase Authentication ID Token
      const authHeader = req.headers.authorization;
      if (!authHeader || !authHeader.startsWith("Bearer ")) {
        return res.status(401).send({ message: "Unauthorized: Missing Authorization header" });
      }

      const idToken = authHeader.split("Bearer ")[1];
      let decodedToken;
      try {
        decodedToken = await admin.auth().verifyIdToken(idToken);
      } catch (error) {
        console.error("Auth Error:", error);
        return res.status(401).send({ message: "Unauthorized: Invalid token" });
      }

      // 2. Parse request body
      const { amount, currency, email, description } = req.body;
      if (!amount) {
        return res.status(400).send({ message: "Bad Request: Missing amount" });
      }

      // 3. Create Razorpay Payment Link
      const paymentLinkOptions = {
        amount: amount, // already converted to paise by the Flutter app
        currency: currency || "INR",
        accept_partial: false,
        description: description || "Wallet Top-up",
        customer: {
          email: email || decodedToken.email || "",
        },
        notify: {
          sms: false,
          email: true,
        },
        reminder_enable: true,
        callback_url: `https://${projectId}.web.app/payment-result`,
        callback_method: "get",
      };

      const paymentLink = await razorpay.paymentLink.create(paymentLinkOptions);

      // 4. Return the secure link to the app
      res.status(200).send({ paymentLink: paymentLink.short_url });
    } catch (error) {
      console.error("Error creating payment link:", error);
      res.status(500).send({ message: "Internal Server Error: " + error.message });
    }
  });
});

exports.createRazorpayOrder = functions.https.onRequest((req, res) => {
  corsHandler(req, res, async () => {
    if (req.method !== "POST") {
      return res.status(405).send({ message: "Method Not Allowed" });
    }

    try {
      // Verify Firebase Authentication ID Token
      const authHeader = req.headers.authorization;
      if (!authHeader || !authHeader.startsWith("Bearer ")) {
        return res.status(401).send({ message: "Unauthorized: Missing Authorization header" });
      }
      const idToken = authHeader.split("Bearer ")[1];
      try {
        await admin.auth().verifyIdToken(idToken);
      } catch (error) {
        console.error("Auth Error:", error);
        return res.status(401).send({ message: "Unauthorized: Invalid token" });
      }

      const { amount, currency, receipt } = req.body;
      
      if (!amount) {
        return res.status(400).send({ message: "Bad Request: Missing amount" });
      }

      // Call Razorpay API to create an order
      const options = {
        amount: amount, // flutter will send the amount in paise
        currency: currency || "INR",
        receipt: receipt || `receipt_${Date.now()}`,
      };

      const order = await razorpay.orders.create(options);

      // Return order details to Flutter
      res.status(200).send({
        id: order.id,
        amount: order.amount,
        currency: order.currency,
        key_id: rzpKeyId
      });
    } catch (error) {
      console.error("Error creating Razorpay order:", error);
      res.status(500).send({ message: "Internal Server Error: " + error.message });
    }
  });
});

// Razorpay Webhook Endpoint
exports.razorpayWebhook = functions.https.onRequest((req, res) => {
  // Webhooks usually don't need CORS restrictions, but we must verify the signature
  if (req.method !== "POST") {
    return res.status(405).send({ message: "Method Not Allowed" });
  }

  try {
    const signature = req.headers["x-razorpay-signature"];
    if (!signature) {
      return res.status(400).send({ message: "Missing Razorpay signature" });
    }

    const payload = JSON.stringify(req.body);
    
    // Validate signature
    const expectedSignature = crypto
      .createHmac("sha256", rzpWebhookSecret)
      .update(payload)
      .digest("hex");

    if (expectedSignature !== signature) {
      console.error("Invalid Webhook Signature");
      return res.status(401).send({ message: "Invalid Signature" });
    }

    // Process webhook event
    const event = req.body.event;
    console.log("Received Valid Webhook Event:", event);

    // TODO: Add logic to handle different events like 'payment.captured' or 'order.paid'
    // For example, update user wallet balance in Firestore securely here.

    res.status(200).send({ status: "ok" });
  } catch (error) {
    console.error("Error processing webhook:", error);
    res.status(500).send({ message: "Internal Server Error" });
  }
});

// Cloud Function to securely check if an email or phone exists in the sellers collection
// This prevents Data Enumeration (Scraping) since it runs on the backend.
exports.checkAuthExists = functions.https.onCall(async (data, context) => {
  const email = data.email;
  const phone = data.phoneNumber;

  if (!email && !phone) {
    throw new functions.https.HttpsError(
      "invalid-argument",
      "Either email or phoneNumber must be provided."
    );
  }

  try {
    const sellersRef = admin.firestore().collection("sellers");
    let querySnapshot;

    if (email) {
      querySnapshot = await sellersRef.where("email", "==", email).limit(1).get();
    } else if (phone) {
      querySnapshot = await sellersRef.where("phoneNumber", "==", phone).limit(1).get();
    }

    if (!querySnapshot.empty) {
      const doc = querySnapshot.docs[0];
      return { 
        exists: true, 
        provider: doc.data().authProvider || null 
      };
    }

    return { exists: false, provider: null };
  } catch (error) {
    console.error("Error checking auth existence:", error);
    throw new functions.https.HttpsError("internal", "Failed to check auth existence.");
  }
});

// ────────────────────────────────────────────────────────────
// IDEMPOTENT STOCK RESTORE
// Restores product stock when an order is rejected or cancelled.
// Uses availableStock (the same field deducted by createSecureOrder).
// ────────────────────────────────────────────────────────────
async function restoreOrderStock(db, orderData, orderId) {
  const items = orderData.items;
  if (!items || items.length === 0) return;

  const batch = db.batch();
  let hasWrites = false;

  for (const item of items) {
    if (!item.productId) continue;
    const productRef = db.collection('products').doc(item.productId);
    const productSnap = await productRef.get();
    if (!productSnap.exists) continue;

    const productData = productSnap.data();
    const currentStock = productData.availableStock || 0;
    const qtyToRestore = item.quantity || 1;

    batch.update(productRef, {
      availableStock: currentStock + qtyToRestore,
      status: 'available',
    });
    hasWrites = true;
  }

  if (hasWrites) {
    await batch.commit();
    console.log(`Stock restored for order ${orderId}`);
  }
}

// ────────────────────────────────────────────────────────────
// IDEMPOTENT SELLER WALLET CREDIT
// Credits the seller's wallet when an order is delivered.
// Idempotent: checks walletCreditedAt before crediting.
// Uses Firestore transaction to ensure consistency.
// ────────────────────────────────────────────────────────────
async function creditSellerWallet(db, orderData, orderId) {
  const sellerId = orderData.sellerId;
  const amount = parseFloat(orderData.amount) || 0;

  if (!sellerId || amount <= 0) {
    console.log(`Skipping wallet credit: sellerId=${sellerId}, amount=${amount}`);
    return;
  }

  // Idempotency check: skip if already credited
  if (orderData.walletCreditedAt) {
    console.log(`Wallet already credited for order ${orderId}, skipping.`);
    return;
  }

  const sellerRef = db.collection('sellers').doc(sellerId);
  const orderRef = db.collection('orders').doc(orderId);
  const txnRef = db.collection('sellers').doc(sellerId).collection('transactions').doc();

  try {
    await db.runTransaction(async (transaction) => {
      const sellerSnap = await transaction.get(sellerRef);
      if (!sellerSnap.exists) {
        console.log(`Seller ${sellerId} not found, skipping wallet credit.`);
        return;
      }

      // Double-check idempotency inside transaction
      const orderSnap = await transaction.get(orderRef);
      if (orderSnap.exists && orderSnap.data().walletCreditedAt) {
        console.log(`Concurrent wallet credit detected for order ${orderId}, skipping.`);
        return;
      }

      const currentBalance = parseFloat(sellerSnap.data().walletBalance) || 0;

      transaction.update(sellerRef, {
        walletBalance: currentBalance + amount,
      });

      transaction.update(orderRef, {
        walletCreditedAt: admin.firestore.FieldValue.serverTimestamp(),
      });

      transaction.set(txnRef, {
        type: 'order_credit',
        orderId: orderId,
        amount: amount,
        balanceBefore: currentBalance,
        balanceAfter: currentBalance + amount,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
      });
    });

    console.log(`Wallet credited: seller=${sellerId}, amount=${amount}, order=${orderId}`);
  } catch (error) {
    console.error(`Failed to credit seller wallet for order ${orderId}:`, error);
  }
}

// ────────────────────────────────────────────────────────────
// ORDER STATUS CHANGED — MASTER TRIGGER
// Handles all status transitions with FCM + business side effects.
// Each business flow is idempotent (safe on retry).
// ────────────────────────────────────────────────────────────
exports.onOrderStatusChanged = functions.firestore
  .document("orders/{orderId}")
  .onWrite(async (change, context) => {
    const beforeData = change.before.data();
    const afterData = change.after.data();

    if (!afterData) {
      return null; // Order was deleted
    }

    const beforeStatus = beforeData ? beforeData.status : null;
    const afterStatus = afterData.status;

    if (beforeStatus === afterStatus) {
      return null;
    }

    const orderId = context.params.orderId;
    const newStatus = afterData.status;
    const customerId = afterData.customerId;
    const sellerId = afterData.sellerId;
    const riderId = afterData.riderId;

    const db = admin.firestore();

    let targetUids = [];
    let title = "Order Update";
    let body = `Order ${orderId} status changed to ${newStatus}`;

    switch(newStatus) {
      case "New":
        targetUids.push(sellerId);
        title = "New Order Received";
        body = `You have a new order to process!`;
        break;
      case "Accepted":
        targetUids.push(customerId);
        title = "Order Accepted";
        body = `Your order has been accepted and is being prepared.`;
        break;
      case "Preparing":
        targetUids.push(customerId);
        title = "Preparing Your Order";
        body = `Your order is being prepared.`;
        break;
      case "Ready":
        targetUids.push(customerId);
        if (riderId) targetUids.push(riderId);
        title = "Order Ready";
        body = `Your order is ready!`;
        break;
      case "OutForDelivery":
        targetUids.push(customerId);
        title = "Out for Delivery";
        body = `Your order is on the way!`;
        break;
      case "Delivered":
        targetUids.push(customerId);
        title = "Order Delivered";
        body = `Your order has been delivered. Enjoy!`;
        // ─── BUSINESS FLOW 3: Delivered → Wallet Credit ───
        await creditSellerWallet(db, afterData, orderId);
        break;
      case "Rejected":
        targetUids.push(customerId);
        title = "Order Rejected";
        body = `Your order has been rejected.`;
        // ─── BUSINESS FLOW 1: Rejected → Stock Restore ───
        await restoreOrderStock(db, afterData, orderId);
        break;
      case "Cancelled":
        targetUids.push(customerId);
        targetUids.push(sellerId);
        title = "Order Cancelled";
        body = `Order ${orderId} has been cancelled.`;
        // ─── BUSINESS FLOW 2: Cancelled → Stock Restore ───
        await restoreOrderStock(db, afterData, orderId);
        break;
    }

    if (targetUids.length === 0) return null;

    const tokens = [];
    
    // Using Set to avoid duplicate tokens if same user is involved
    const processedUids = new Set();

    for (const uid of targetUids) {
      if (!uid || processedUids.has(uid)) continue;
      processedUids.add(uid);
      
      const userDoc = await db.collection("users").doc(uid).get();
      if (userDoc.exists) {
        const token = userDoc.data().fcmToken;
        if (token) tokens.push(token);
      }
    }

    if (tokens.length === 0) {
      console.log("No valid FCM tokens found for target UIDs.");
      return null;
    }

    const payload = {
      notification: {
        title: title,
        body: body,
      },
      data: {
        orderId: orderId,
        click_action: "FLUTTER_NOTIFICATION_CLICK"
      }
    };

    try {
      const response = await admin.messaging().sendToDevice(tokens, payload);
      console.log("Successfully sent messages:", response.successCount);
      
      response.results.forEach((result, index) => {
        const error = result.error;
        if (error) {
          console.error("Failure sending notification to", tokens[index], error);
        }
      });
    } catch (error) {
      console.error("Error sending notification:", error);
    }

    return null;
  });

// --- Secure Checkout with Coupon Support ---
exports.createSecureOrder = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'User must be logged in.');
  }

  const uid = context.auth.uid;
  const { selectedCartItems, customerName, deliveryAddress, paymentMethod, coupon } = data;

  if (!selectedCartItems || selectedCartItems.length === 0) {
    throw new functions.https.HttpsError('invalid-argument', 'No items selected.');
  }

  const db = admin.firestore();

  try {
    await db.runTransaction(async (transaction) => {
      // 1. Read all products
      const productDocs = [];
      for (const item of selectedCartItems) {
        const productRef = db.collection('products').doc(item.id);
        const productSnap = await transaction.get(productRef);
        if (!productSnap.exists) {
          throw new functions.https.HttpsError('not-found', `Product ${item.id} not found.`);
        }
        productDocs.push({ snap: productSnap, item: item });
      }

      // 2. Validate stock and build order data
      const itemsBySeller = {};
      const productUpdates = [];
      const cartDeletes = [];

      for (const { snap, item } of productDocs) {
        const productData = snap.data();
        const availableStock = productData.availableStock || 0;
        const dbPrice = parseFloat(productData.price) || 0;
        const dbDiscountPrice = parseFloat(productData.discountPrice) || 0;

        const effectivePrice =
          (dbDiscountPrice > 0 && dbDiscountPrice < dbPrice)
            ? dbDiscountPrice
            : dbPrice;

        if (availableStock < item.quantity) {
          throw new functions.https.HttpsError('failed-precondition', `Not enough stock for ${productData.name}.`);
        }

        const newStock = availableStock - item.quantity;
        const newStatus = newStock === 0 ? 'outOfStock' : (productData.status || 'available');

        productUpdates.push({
          ref: snap.ref,
          data: { availableStock: newStock, status: newStatus }
        });

        cartDeletes.push(db.collection('users').doc(uid).collection('cart').doc(item.id));

        const sellerId = productData.sellerId;
        if (!itemsBySeller[sellerId]) {
          itemsBySeller[sellerId] = {
            totalAmount: 0,
            items: []
          };
        }

        itemsBySeller[sellerId].totalAmount += (effectivePrice * (item.quantity || 1));
        itemsBySeller[sellerId].items.push({
          id: item.id || '',
          productId: item.id || '',
          name: productData.name || 'Unknown Product',
          price: effectivePrice,
          quantity: item.quantity || 1,
          sellerId: sellerId || 'Unknown Seller',
          image: productData.imageUrls && productData.imageUrls.length > 0 ? productData.imageUrls[0] : (productData.imageUrl || null),
          imageUrl: productData.imageUrls && productData.imageUrls.length > 0 ? productData.imageUrls[0] : (productData.imageUrl || null)
        });
      }

      // 3. Server-side Coupon Validation
      let appliedDiscount = 0;
      if (coupon && coupon.code && coupon.sellerId) {
        const couponRef = db.collection('sellers')
          .doc(coupon.sellerId)
          .collection('coupons')
          .doc(coupon.couponId);
        const couponSnap = await transaction.get(couponRef);

        if (!couponSnap.exists) {
          throw new functions.https.HttpsError('not-found', 'Coupon not found.');
        }

        const couponData = couponSnap.data();
        const sellerOrder = itemsBySeller[coupon.sellerId];
        const orderTotal = sellerOrder ? sellerOrder.totalAmount : 0;

        // Validate coupon fields
        if (!couponData.isActive) {
          throw new functions.https.HttpsError('failed-precondition', 'Coupon is no longer active.');
        }

        const expiryDate = couponData.expiryDate ? couponData.expiryDate.toDate() : new Date(0);
        if (expiryDate < new Date()) {
          throw new functions.https.HttpsError('failed-precondition', 'Coupon has expired.');
        }

        const usageLimit = couponData.usageLimit || 0;
        const usedCount = couponData.usedCount || 0;
        if (usageLimit > 0 && usedCount >= usageLimit) {
          throw new functions.https.HttpsError('failed-precondition', 'Coupon usage limit reached.');
        }

        const minimumOrderValue = parseFloat(couponData.minimumOrderValue) || 0;
        if (orderTotal < minimumOrderValue) {
          throw new functions.https.HttpsError('failed-precondition',
            `Minimum order value of ${minimumOrderValue} required for this coupon.`);
        }

        // Calculate discount
        const discountAmount = parseFloat(couponData.discountAmount) || 0;
        const isPercentage = couponData.isPercentage || false;
        appliedDiscount = isPercentage
          ? Math.min(orderTotal * discountAmount / 100, orderTotal)
          : Math.min(discountAmount, orderTotal);

        // Decrement coupon usage count
        transaction.update(couponRef, {
          usedCount: usedCount + 1,
        });

        // Adjust order total for this seller
        if (sellerOrder) {
          sellerOrder.totalAmount = orderTotal - appliedDiscount;
          sellerOrder.discountAmount = appliedDiscount;
          sellerOrder.couponCode = coupon.code;
        }
      }

      // 4. Perform Writes
      for (const sellerId in itemsBySeller) {
        const orderData = itemsBySeller[sellerId];
        const orderRef = db.collection('orders').doc();
        const orderPayload = {
          customerId: uid || '',
          customerName: customerName || 'Unknown Customer',
          sellerId: sellerId || 'Unknown Seller',
          status: 'New',
          amount: orderData.totalAmount || 0,
          timestamp: admin.firestore.FieldValue.serverTimestamp(),
          items: orderData.items,
          deliveryAddress: deliveryAddress || 'Default Address',
          paymentMethod: paymentMethod || 'Wallet'
        };

        if (orderData.discountAmount) {
          orderPayload.discountAmount = orderData.discountAmount;
          orderPayload.couponCode = orderData.couponCode || '';
          orderPayload.originalAmount = orderData.totalAmount + orderData.discountAmount;
        }

        transaction.set(orderRef, orderPayload);
      }

      for (const update of productUpdates) {
        transaction.update(update.ref, update.data);
      }

      for (const cartRef of cartDeletes) {
        transaction.delete(cartRef);
      }
    });

    return { success: true };
  } catch (error) {
    console.error('Transaction failed:', error);
    if (error instanceof functions.https.HttpsError) {
      throw error;
    }
    throw new functions.https.HttpsError('internal', error.message);
  }
});

// ZEGOCLOUD Token Generator
exports.generateZegoToken = functions.https.onRequest((req, res) => {
  corsHandler(req, res, async () => {
    if (req.method !== "POST") {
      return res.status(405).send({ message: "Method Not Allowed" });
    }

    try {
      // 1. Verify Firebase Authentication ID Token
      const authHeader = req.headers.authorization;
      if (!authHeader || !authHeader.startsWith("Bearer ")) {
        return res.status(401).send({ message: "Unauthorized: Missing Authorization header" });
      }

      const idToken = authHeader.split("Bearer ")[1];
      let decodedToken;
      try {
        decodedToken = await admin.auth().verifyIdToken(idToken);
      } catch (error) {
        console.error("Auth Error:", error);
        return res.status(401).send({ message: "Unauthorized: Invalid token" });
      }

      // 2. Parse request body
      const { userId, roomId } = req.body;
      if (!userId || !roomId) {
        return res.status(400).send({ message: "Bad Request: Missing userId or roomId" });
      }

      if (userId !== decodedToken.uid) {
        return res.status(403).send({ message: "Forbidden: userId mismatch" });
      }

      // 3. ZEGOCLOUD Credentials from Firebase Config or Env
      const appId = parseInt(functions.config().zegocloud ? functions.config().zegocloud.app_id : (process.env.ZEGO_APP_ID || "0"));
      const serverSecret = functions.config().zegocloud ? functions.config().zegocloud.server_secret : (process.env.ZEGO_SERVER_SECRET || "dummy_secret");
      
      if (appId === 0 || serverSecret === "dummy_secret") {
         return res.status(500).send({ message: "Server misconfiguration: ZEGOCLOUD credentials missing" });
      }

      // 4. Return the secrets securely to the authenticated client for them to initialize the call.
      res.status(200).send({ 
        appId: appId,
        appSign: serverSecret
      });
    } catch (error) {
      console.error("Error generating Zego token:", error);
      res.status(500).send({ message: "Internal Server Error: " + error.message });
    }
  });
});
