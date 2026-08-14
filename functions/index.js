const functions = require("firebase-functions/v1");
const { onCall: onCallV2, HttpsError: HttpsErrorV2 } = require("firebase-functions/v2/https");
const admin = require("firebase-admin");
const cors = require("cors");
const crypto = require("crypto");

if (!admin.apps.length) {
  admin.initializeApp();
}

const corsHandler = cors({ origin: true });

// Lazy module getters to prevent deployment initialization timeouts
let _bcrypt = null;
function getBcrypt() {
  if (!_bcrypt) {
    _bcrypt = require("bcryptjs");
  }
  return _bcrypt;
}

let _razorpay = null;
function getRazorpayInstance() {
  if (!_razorpay) {
    const Razorpay = require("razorpay");
    const keyId = process.env.RAZORPAY_KEY_ID || process.env.RAZORPAY_API_KEY || "dummy_key_id";
    const keySecret = process.env.RAZORPAY_KEY_SECRET || "dummy_key_secret";
    try {
      _razorpay = new Razorpay({ key_id: keyId, key_secret: keySecret });
    } catch (err) {
      console.warn("Razorpay initialization warning:", err.message);
    }
  }
  return _razorpay;
}

function getWebhookSecret() {
  return process.env.RAZORPAY_WEBHOOK_SECRET || "dummy_webhook_secret";
}

// Phone Number Normalization
function normalizePhoneVariations(rawPhone) {
  if (!rawPhone) return [];
  const digitsOnly = String(rawPhone).replace(/\D/g, "");
  if (digitsOnly.length === 0) return [String(rawPhone).trim()];

  const variations = new Set();
  variations.add(digitsOnly);
  variations.add(`+${digitsOnly}`);

  let last10 = digitsOnly;
  if (digitsOnly.length >= 10) {
    last10 = digitsOnly.slice(-10);
  }

  variations.add(last10);
  variations.add(`+91${last10}`);
  variations.add(`+91 ${last10}`);
  variations.add(`0${last10}`);
  variations.add(`91${last10}`);
  variations.add(`+91-${last10}`);

  if (last10.length === 10) {
    const part1 = last10.slice(0, 5);
    const part2 = last10.slice(5);
    variations.add(`${part1} ${part2}`);
    variations.add(`${part1}-${part2}`);
    variations.add(`+91 ${part1} ${part2}`);
    variations.add(`+91 ${part1}-${part2}`);
  }

  const trimmedRaw = String(rawPhone).trim();
  if (trimmedRaw.length > 0) {
    variations.add(trimmedRaw);
  }

  return Array.from(variations);
}

const SEARCHABLE_USER_COLLECTIONS = [
  "delivery_partners",
  "delivery_partner",
  "delivery_users",
  "users",
  "buyer_user",
  "buyer_users",
  "sellers",
  "seller",
  "seller_users",
  "customers",
  "customer",
  "riders",
  "partners",
];

const SEARCHABLE_PHONE_FIELDS = [
  "phone",
  "phoneNumber",
  "contactNumber",
  "mobile",
  "mobileNumber",
  "userPhone",
  "customerPhone",
  "partnerPhone",
  "sellerPhone",
];

const CANDIDATE_PASSWORD_FIELDS = [
  "password",
  "hashedPassword",
  "pass",
  "pwd",
  "pin",
  "secret",
  "authPassword",
  "userPassword",
  "password_hash",
  "passwordHash",
  "user_password",
  "account_password",
  "pass_hash",
  "plainPassword",
  "plain_password",
  "pWord",
];

// 1. Payment Link Generation
exports.createPaymentLink = functions.https.onRequest((req, res) => {
  corsHandler(req, res, async () => {
    if (req.method !== "POST") {
      return res.status(405).send({ message: "Method Not Allowed" });
    }

    try {
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

      const { amount, currency, description, customer } = req.body;
      if (!amount || amount <= 0) {
        return res.status(400).send({ message: "Bad Request: Invalid amount" });
      }

      const rzp = getRazorpayInstance();
      const paymentLink = await rzp.paymentLink.create({
        amount: Math.round(amount * 100),
        currency: currency || "INR",
        accept_partial: false,
        description: description || "Food Delivery Order Payment",
        customer: {
          name: customer?.name || decodedToken.name || "Customer",
          email: customer?.email || decodedToken.email || "customer@example.com",
          contact: customer?.contact || decodedToken.phone_number || "+919876543210",
        },
        notify: {
          sms: true,
          email: true,
        },
        reminder_enable: true,
        callback_url: `https://${process.env.GCLOUD_PROJECT || "food-delivery-app-cd4ca"}.web.app/payment-success`,
        callback_method: "get",
      });

      res.status(200).send({
        success: true,
        paymentLinkId: paymentLink.id,
        shortUrl: paymentLink.short_url,
        status: paymentLink.status,
      });
    } catch (error) {
      console.error("Error creating payment link:", error);
      res.status(500).send({ message: "Internal Server Error: " + error.message });
    }
  });
});

// 2. Razorpay Order Creation
exports.createRazorpayOrder = functions.https.onRequest((req, res) => {
  corsHandler(req, res, async () => {
    if (req.method !== "POST") {
      return res.status(405).send({ message: "Method Not Allowed" });
    }

    try {
      const authHeader = req.headers.authorization;
      if (!authHeader || !authHeader.startsWith("Bearer ")) {
        return res.status(401).send({ message: "Unauthorized: Missing Authorization header" });
      }

      const idToken = authHeader.split("Bearer ")[1];
      try {
        await admin.auth().verifyIdToken(idToken);
      } catch (error) {
        return res.status(401).send({ message: "Unauthorized: Invalid token" });
      }

      const { amount, currency, receipt } = req.body;
      if (!amount || amount <= 0) {
        return res.status(400).send({ message: "Bad Request: Invalid amount" });
      }

      const rzp = getRazorpayInstance();
      const order = await rzp.orders.create({
        amount: Math.round(amount * 100),
        currency: currency || "INR",
        receipt: receipt || `receipt_${Date.now()}`,
      });

      res.status(200).send({
        success: true,
        orderId: order.id,
        amount: order.amount,
        currency: order.currency,
      });
    } catch (error) {
      console.error("Error creating Razorpay order:", error);
      res.status(500).send({ message: "Internal Server Error: " + error.message });
    }
  });
});

// 3. Razorpay Webhook
exports.razorpayWebhook = functions.https.onRequest((req, res) => {
  corsHandler(req, res, async () => {
    if (req.method !== "POST") {
      return res.status(405).send({ message: "Method Not Allowed" });
    }

    try {
      const signature = req.headers["x-razorpay-signature"];
      const webhookSecret = getWebhookSecret();

      const expectedSignature = crypto
        .createHmac("sha256", webhookSecret)
        .update(JSON.stringify(req.body))
        .digest("hex");

      if (signature !== expectedSignature) {
        console.warn("Webhook signature mismatch");
        return res.status(400).send({ message: "Invalid signature" });
      }

      const event = req.body.event;
      const payload = req.body.payload;

      const db = admin.firestore();

      if (event === "payment.captured" || event === "payment_link.paid") {
        const paymentEntity = payload.payment ? payload.payment.entity : payload.payment_link.entity;
        const notes = paymentEntity.notes || {};
        const orderId = notes.orderId || notes.order_id;

        if (orderId) {
          await db.collection("orders").doc(orderId).update({
            paymentStatus: "paid",
            razorpayPaymentId: paymentEntity.id,
            updatedAt: admin.firestore.FieldValue.serverTimestamp(),
          });
          console.log(`Payment confirmed for order ${orderId}`);
        }
      }

      res.status(200).send({ status: "ok" });
    } catch (error) {
      console.error("Webhook processing error:", error);
      res.status(500).send({ message: "Webhook error: " + error.message });
    }
  });
});

// 4. Check Auth Exists
exports.checkAuthExists = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError(
      "unauthenticated",
      "Authentication is required to check account existence."
    );
  }

  const { email, phoneNumber } = data || {};

  if (!email && !phoneNumber) {
    throw new HttpsError(
      "invalid-argument",
      "Either email or phoneNumber must be provided."
    );
  }

  try {
    const db = admin.firestore();
    let foundDoc = null;
    let foundCollection = null;

    if (email) {
      const trimmedEmail = String(email).trim();
      for (const coll of SEARCHABLE_USER_COLLECTIONS) {
        const snap = await db.collection(coll).where("email", "==", trimmedEmail).limit(1).get();
        if (!snap.empty) {
          foundDoc = snap.docs[0];
          foundCollection = coll;
          break;
        }
      }
    } else if (phoneNumber) {
      const pVariations = normalizePhoneVariations(phoneNumber);
      for (const coll of SEARCHABLE_USER_COLLECTIONS) {
        for (const field of SEARCHABLE_PHONE_FIELDS) {
          for (const pVal of pVariations) {
            if (!pVal) continue;
            const snap = await db.collection(coll).where(field, "==", pVal).limit(1).get();
            if (!snap.empty) {
              foundDoc = snap.docs[0];
              foundCollection = coll;
              break;
            }
          }
          if (foundDoc) break;
        }
        if (foundDoc) break;
      }
    }

    if (foundDoc) {
      return {
        exists: true,
        provider: foundDoc.data().authProvider || null,
        collection: foundCollection,
      };
    }

    return { exists: false, provider: null };
  } catch (error) {
    console.error("Error checking auth existence:", error);
    throw new functions.https.HttpsError("internal", "Failed to check auth existence.");
  }
});

// Helper Functions for Stock and Wallet
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

async function creditSellerWallet(db, orderData, orderId) {
  const sellerId = orderData.sellerId;
  const amount = parseFloat(orderData.amount) || 0;

  if (!sellerId || amount <= 0) return;
  if (orderData.walletCreditedAt) return;

  const sellerRef = db.collection('sellers').doc(sellerId);
  const orderRef = db.collection('orders').doc(orderId);
  const txnRef = db.collection('sellers').doc(sellerId).collection('transactions').doc();

  try {
    await db.runTransaction(async (transaction) => {
      const sellerSnap = await transaction.get(sellerRef);
      if (!sellerSnap.exists) return;

      const orderSnap = await transaction.get(orderRef);
      if (orderSnap.exists && orderSnap.data().walletCreditedAt) return;

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
  } catch (error) {
    console.error(`Failed to credit seller wallet for order ${orderId}:`, error);
  }
}

async function creditDeliveryPartnerWallet(db, orderData, orderId) {
  const riderId = orderData.riderId;
  const amount = parseFloat(orderData.amount) || 0;

  if (!riderId || amount <= 0) return;
  if (orderData.deliveryPartnerCreditedAt) return;

  const deliveryEarnings = (amount * 0.15) + 40.0;
  const partnerRef = db.collection('delivery_partners').doc(riderId);
  const orderRef = db.collection('orders').doc(orderId);
  const txnRef = db.collection('delivery_partners').doc(riderId).collection('transactions').doc();

  try {
    await db.runTransaction(async (transaction) => {
      const partnerSnap = await transaction.get(partnerRef);
      if (!partnerSnap.exists) return;

      const orderSnap = await transaction.get(orderRef);
      if (orderSnap.exists && orderSnap.data().deliveryPartnerCreditedAt) return;

      const currentEarnings = parseFloat(partnerSnap.data().totalEarnings) || 0;
      const currentDeliveries = (partnerSnap.data().totalDeliveries) || 0;

      transaction.update(partnerRef, {
        totalEarnings: currentEarnings + deliveryEarnings,
        totalDeliveries: currentDeliveries + 1,
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      });

      transaction.update(orderRef, {
        deliveryPartnerCreditedAt: admin.firestore.FieldValue.serverTimestamp(),
      });

      transaction.set(txnRef, {
        type: 'delivery_earning',
        orderId: orderId,
        amount: deliveryEarnings,
        totalEarnings: currentEarnings + deliveryEarnings,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
      });
    });
  } catch (error) {
    console.error(`Failed to credit delivery partner for order ${orderId}:`, error);
  }
}

// 5. Order Status Trigger (v2 Firestore trigger)
exports.onOrderStatusChanged = functions.firestore.document("orders/{orderId}").onWrite(async (change, context) => {
  const beforeData = change.before ? change.before.data() : null;
  const afterData = change.after ? change.after.data() : null;

  if (!afterData) return null;

  const beforeStatus = beforeData ? beforeData.status : null;
  const afterStatus = afterData.status;

  if (beforeStatus === afterStatus) return null;

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
      if (sellerId) targetUids.push(sellerId);
      title = "New Order Received";
      body = "You have a new order to process!";
      break;
    case "Accepted":
      if (customerId) targetUids.push(customerId);
      title = "Order Accepted";
      body = "Your order has been accepted and is being prepared.";
      break;
    case "Preparing":
      if (customerId) targetUids.push(customerId);
      title = "Preparing Your Order";
      body = "Your order is being prepared.";
      break;
    case "Ready":
      if (customerId) targetUids.push(customerId);
      if (riderId) targetUids.push(riderId);
      title = "Order Ready";
      body = "Your order is ready!";
      break;
    case "OutForDelivery":
      if (customerId) targetUids.push(customerId);
      title = "Out for Delivery";
      body = "Your order is on the way!";
      break;
    case "Delivered":
      if (customerId) targetUids.push(customerId);
      title = "Order Delivered";
      body = "Your order has been delivered. Enjoy!";
      await creditSellerWallet(db, afterData, orderId);
      await creditDeliveryPartnerWallet(db, afterData, orderId);
      break;
    case "Rejected":
      if (customerId) targetUids.push(customerId);
      title = "Order Rejected";
      body = "Your order has been rejected.";
      await restoreOrderStock(db, afterData, orderId);
      break;
    case "Cancelled":
      if (customerId) targetUids.push(customerId);
      if (sellerId) targetUids.push(sellerId);
      title = "Order Cancelled";
      body = `Order ${orderId} has been cancelled.`;
      await restoreOrderStock(db, afterData, orderId);
      break;
  }

  if (targetUids.length === 0) return null;

  const tokens = [];
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

  if (tokens.length === 0) return null;

  const payload = {
    notification: { title, body },
    data: { orderId, click_action: "FLUTTER_NOTIFICATION_CLICK" }
  };

  try {
    const response = await admin.messaging().sendToDevice(tokens, payload);
    console.log("Successfully sent messages:", response.successCount);
  } catch (error) {
    console.error("Error sending notification:", error);
  }

  return null;
});

// 6. Secure Order Creation
exports.createSecureOrder = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'User must be logged in.');
  }

  const uid = context.auth.uid;
  const { selectedCartItems, customerName, customerPhone, deliveryAddress, paymentMethod, coupon } = data || {};

  if (!selectedCartItems || selectedCartItems.length === 0) {
    throw new HttpsError('invalid-argument', 'No items selected.');
  }

  const db = admin.firestore();

  try {
    await db.runTransaction(async (transaction) => {
      const productDocs = [];
      for (const item of selectedCartItems) {
        const productRef = db.collection('products').doc(item.id);
        const productSnap = await transaction.get(productRef);
        if (!productSnap.exists) {
          throw new HttpsError('not-found', `Product ${item.id} not found.`);
        }
        productDocs.push({ snap: productSnap, item: item });
      }

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
          throw new HttpsError('failed-precondition', `Not enough stock for ${productData.name}.`);
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

      let appliedDiscount = 0;
      if (coupon && coupon.code && coupon.sellerId) {
        const couponRef = db.collection('sellers')
          .doc(coupon.sellerId)
          .collection('coupons')
          .doc(coupon.couponId);
        const couponSnap = await transaction.get(couponRef);

        if (!couponSnap.exists) {
          throw new HttpsError('not-found', 'Coupon not found.');
        }

        const couponData = couponSnap.data();
        const sellerOrder = itemsBySeller[coupon.sellerId];
        const orderTotal = sellerOrder ? sellerOrder.totalAmount : 0;

        if (!couponData.isActive) {
          throw new HttpsError('failed-precondition', 'Coupon is no longer active.');
        }

        const expiryDate = couponData.expiryDate ? couponData.expiryDate.toDate() : new Date(0);
        if (expiryDate < new Date()) {
          throw new HttpsError('failed-precondition', 'Coupon has expired.');
        }

        const usageLimit = couponData.usageLimit || 0;
        const usedCount = couponData.usedCount || 0;
        if (usageLimit > 0 && usedCount >= usageLimit) {
          throw new HttpsError('failed-precondition', 'Coupon usage limit reached.');
        }

        const minimumOrderValue = parseFloat(couponData.minimumOrderValue) || 0;
        if (orderTotal < minimumOrderValue) {
          throw new HttpsError('failed-precondition', `Minimum order value of ${minimumOrderValue} required for this coupon.`);
        }

        const discountAmount = parseFloat(couponData.discountAmount) || 0;
        const isPercentage = couponData.isPercentage || false;
        appliedDiscount = isPercentage
          ? Math.min(orderTotal * discountAmount / 100, orderTotal)
          : Math.min(discountAmount, orderTotal);

        transaction.update(couponRef, {
          usedCount: usedCount + 1,
        });

        if (sellerOrder) {
          sellerOrder.totalAmount = orderTotal - appliedDiscount;
          sellerOrder.discountAmount = appliedDiscount;
          sellerOrder.couponCode = coupon.code;
        }
      }

      let finalName = customerName && customerName !== 'Customer' && customerName !== 'Unknown Customer' ? customerName : '';
      let finalPhone = customerPhone || '';
      let finalAddress = deliveryAddress && deliveryAddress !== 'Primary Address' && deliveryAddress !== 'Default Address' ? deliveryAddress : '';

      if ((!finalName || !finalPhone || !finalAddress) && uid) {
        const userRef = db.collection('users').doc(uid);
        const userSnap = await transaction.get(userRef);
        if (userSnap.exists) {
          const uData = userSnap.data() || {};
          if (!finalName) {
            finalName = uData.name || uData.displayName || uData.fullName || uData.userName || '';
          }
          if (!finalPhone) {
            finalPhone = uData.phone || uData.phoneNumber || uData.mobile || uData.userPhone || '';
          }
          if (!finalAddress) {
            const selType = (uData.selectedAddressType || '').toLowerCase().trim();
            if (selType === 'home' && uData.homeAddress) finalAddress = uData.homeAddress;
            else if (selType === 'work' && uData.workAddress) finalAddress = uData.workAddress;
            else if (selType === 'other' && uData.otherAddress) finalAddress = uData.otherAddress;
            else finalAddress = uData.address || uData.primaryAddress || '';
          }
        }
      }

      if (!finalName) finalName = 'Customer';
      if (!finalAddress) finalAddress = 'Primary Address';

      for (const sellerId in itemsBySeller) {
        const orderData = itemsBySeller[sellerId];
        const orderRef = db.collection('orders').doc();
        const orderPayload = {
          customerId: uid || '',
          customerName: finalName,
          customerPhone: finalPhone,
          sellerId: sellerId || 'Unknown Seller',
          status: 'New',
          amount: orderData.totalAmount || 0,
          timestamp: admin.firestore.FieldValue.serverTimestamp(),
          items: orderData.items,
          deliveryAddress: finalAddress,
          deliveryAddressSnapshot: finalAddress,
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
    if (error instanceof HttpsError) {
      throw error;
    }
    throw new HttpsError('internal', error.message);
  }
});

// 7. ZEGOCLOUD Token Generator
exports.generateZegoToken = functions.https.onRequest((req, res) => {
  corsHandler(req, res, async () => {
    if (req.method !== "POST") {
      return res.status(405).send({ message: "Method Not Allowed" });
    }

    try {
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

      const { userId, roomId } = req.body;
      if (!userId || !roomId) {
        return res.status(400).send({ message: "Bad Request: Missing userId or roomId" });
      }

      if (userId !== decodedToken.uid) {
        return res.status(403).send({ message: "Forbidden: userId mismatch" });
      }

      const appId = parseInt(process.env.ZEGO_APP_ID || "0", 10);
      const serverSecret = process.env.ZEGO_SERVER_SECRET || "dummy_secret";

      if (appId === 0 || serverSecret === "dummy_secret") {
         return res.status(500).send({ message: "Server misconfiguration: ZEGOCLOUD credentials missing" });
      }

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

// 8. Password Reset Request
exports.resetDeliveryPartnerPassword = functions.https.onRequest((req, res) => {
  corsHandler(req, res, async () => {
    if (req.method !== "POST") {
      return res.status(405).send({ message: "Method Not Allowed" });
    }

    try {
      const { phone, email, uid, newPassword } = req.body;
      if ((!phone && !email && !uid) || !newPassword) {
        return res.status(400).send({ message: "Bad Request: Missing parameters" });
      }

      let updatedUids = new Set();

      if (uid) {
        try {
          await admin.auth().updateUser(uid, { password: newPassword });
          updatedUids.add(uid);
        } catch (e) {
          console.log("Error updating by UID:", e.message);
        }
      }

      if (email) {
        try {
          const userByEmail = await admin.auth().getUserByEmail(email);
          await admin.auth().updateUser(userByEmail.uid, { password: newPassword });
          updatedUids.add(userByEmail.uid);
        } catch (e) {
          console.log("Error updating by Email:", e.message);
        }
      }

      if (phone) {
        const cleaned = phone.replaceAll(/\s+/g, '').replaceAll('-', '');
        const fullPhone = cleaned.startsWith('+') ? cleaned : '+91' + cleaned;
        try {
          const userByPhone = await admin.auth().getUserByPhoneNumber(fullPhone);
          await admin.auth().updateUser(userByPhone.uid, { password: newPassword });
          updatedUids.add(userByPhone.uid);
        } catch (e) {
          console.log("Error updating by Phone:", e.message);
        }

        const snapshot = await admin.firestore().collection('delivery_partners')
          .where('phoneNumber', '==', fullPhone)
          .limit(5)
          .get();

        for (const doc of snapshot.docs) {
          try {
            await admin.auth().updateUser(doc.id, { password: newPassword });
            updatedUids.add(doc.id);
          } catch (e) {
            console.log(`Error updating doc ${doc.id}:`, e.message);
          }
        }
      }

      return res.status(200).send({
        success: true,
        updatedCount: updatedUids.size,
        message: `Password reset successfully for ${updatedUids.size} account(s).`
      });
    } catch (error) {
      console.error("Error in resetDeliveryPartnerPassword:", error);
      res.status(500).send({ message: "Internal Server Error: " + error.message });
    }
  });
});

// 9. Custom Login Callable Cloud Function
exports.customLogin = onCallV2({ cors: true }, async (request) => {
  const rawIdentifier = String(
    request.data?.phoneNumber ||
    request.data?.phone ||
    request.data?.email ||
    request.data?.identifier ||
    request.data?.emailOrPhone ||
    ""
  ).trim();
  const rawPassword = String(request.data?.password || "").trim();

  if (rawIdentifier.length === 0 || rawPassword.length === 0) {
    throw new HttpsErrorV2(
      "invalid-argument",
      "Both email/phone number and password are required fields."
    );
  }

  const requestedRole = (
    request.data?.targetRole ||
    request.data?.role ||
    request.data?.appType ||
    ""
  ).toLowerCase().trim();

  const isEmail = rawIdentifier.includes("@");
  const variationsList = isEmail ? [rawIdentifier] : normalizePhoneVariations(rawIdentifier);
  const digitsOnly = rawIdentifier.replace(/\D/g, "");
  const last10 = digitsOnly.length >= 10 ? digitsOnly.slice(-10) : digitsOnly;

  let collectionsToSearch = [...SEARCHABLE_USER_COLLECTIONS];
  if (requestedRole.includes("delivery") || requestedRole.includes("rider") || requestedRole.includes("partner")) {
    collectionsToSearch = [
      "delivery_partners",
      "delivery_partner",
      "delivery_users",
      "riders",
      "partners",
    ];
  } else if (requestedRole.includes("seller") || requestedRole.includes("vendor")) {
    collectionsToSearch = [
      "sellers",
      "seller",
      "seller_users",
    ];
  } else if (requestedRole.includes("buyer") || requestedRole.includes("user") || requestedRole.includes("customer")) {
    collectionsToSearch = [
      "buyer_user",
      "buyer_users",
      "users",
      "customers",
      "customer",
    ];
  }

  try {
    const db = admin.firestore();
    let userDoc = null;
    let foundCollection = null;
    let foundField = null;

    if (isEmail) {
      const lowerEmail = rawIdentifier.toLowerCase();
      for (const coll of collectionsToSearch) {
        for (const eField of ["email", "userEmail", "customerEmail", "sellerEmail", "partnerEmail"]) {
          const snap = await db.collection(coll).where(eField, "==", rawIdentifier).limit(1).get();
          if (!snap.empty) {
            userDoc = snap.docs[0];
            foundCollection = coll;
            foundField = eField;
            break;
          }
          if (rawIdentifier !== lowerEmail) {
            const snapLower = await db.collection(coll).where(eField, "==", lowerEmail).limit(1).get();
            if (!snapLower.empty) {
              userDoc = snapLower.docs[0];
              foundCollection = coll;
              foundField = eField;
              break;
            }
          }
        }
        if (userDoc) break;
      }
    } else {
      for (const coll of collectionsToSearch) {
        for (const field of SEARCHABLE_PHONE_FIELDS) {
          for (const pVal of variationsList) {
            if (!pVal) continue;
            const snap = await db.collection(coll)
              .where(field, "==", pVal)
              .limit(1)
              .get();
            if (!snap.empty) {
              userDoc = snap.docs[0];
              foundCollection = coll;
              foundField = field;
              break;
            }
          }
          if (userDoc) break;
        }
        if (userDoc) break;
      }
    }

    if (!userDoc) {
      console.warn(`customLogin: No document found in Firestore for identifier: ${rawIdentifier}`);
      throw new HttpsErrorV2(
        "not-found",
        "No registered account found with the provided email or phone number."
      );
    }

    const userData = userDoc.data();
    const uid = userDoc.id;

    if (userData.status === "disabled" || userData.status === "blocked" || userData.isActive === false) {
      throw new HttpsErrorV2(
        "permission-denied",
        "Account is deactivated or blocked. Please contact support."
      );
    }

    const candidateHashes = [];
    for (const pField of CANDIDATE_PASSWORD_FIELDS) {
      if (userData[pField] !== undefined && userData[pField] !== null) {
        const val = String(userData[pField]).trim();
        if (val.length > 0 && !candidateHashes.includes(val)) {
          candidateHashes.push(val);
        }
      }
    }

    let isPasswordValid = false;

    if (candidateHashes.length > 0) {
      const bcrypt = getBcrypt();
      for (const candidate of candidateHashes) {
        if (candidate === rawPassword || candidate.trim() === rawPassword) {
          isPasswordValid = true;
          break;
        }
        if (candidate.trim().toLowerCase() === rawPassword.toLowerCase()) {
          isPasswordValid = true;
          break;
        }
        try {
          const bcryptMatch = await bcrypt.compare(rawPassword, candidate) || await bcrypt.compare(rawPassword.trim(), candidate);
          if (bcryptMatch) {
            isPasswordValid = true;
            break;
          }
        } catch (e) {}
        try {
          const md5Hex = crypto.createHash('md5').update(rawPassword).digest('hex');
          if (candidate.toLowerCase() === md5Hex) {
            isPasswordValid = true;
            break;
          }
        } catch (e) {}
        try {
          const sha256Hex = crypto.createHash('sha256').update(rawPassword).digest('hex');
          if (candidate.toLowerCase() === sha256Hex) {
            isPasswordValid = true;
            break;
          }
        } catch (e) {}
      }
    } else {
      console.warn(`customLogin: No password field configured in doc ${uid}. Password validation required.`);
      isPasswordValid = false;
    }

    if (!isPasswordValid) {
      console.warn(`customLogin: Password mismatch for UID ${uid} in collection '${foundCollection}' field '${foundField}'`);
      throw new HttpsErrorV2(
        "unauthenticated",
        "Password is incorrect. Please try again."
      );
    }

    const formattedPhone = last10.length === 10 ? `+91${last10}` : rawIdentifier;

    let effectiveRole = userData.role;
    if (requestedRole.includes("delivery") || requestedRole.includes("rider") || requestedRole.includes("partner")) {
      effectiveRole = "delivery_partner";
    } else if (requestedRole.includes("seller") || requestedRole.includes("vendor")) {
      effectiveRole = "seller";
    } else if (requestedRole.includes("buyer") || requestedRole.includes("user") || requestedRole.includes("customer")) {
      effectiveRole = "user";
    } else {
      const isSellerColl = foundCollection.includes("seller");
      const isDeliveryColl = (foundCollection.includes("delivery") || foundCollection.includes("rider"));
      effectiveRole = userData.role || (isSellerColl ? "seller" : (isDeliveryColl ? "delivery_partner" : "user"));
    }

    const customClaims = {
      role: effectiveRole,
      phoneNumber: formattedPhone,
    };

    const customToken = await admin.auth().createCustomToken(uid, customClaims);

    return {
      success: true,
      customToken: customToken,
      uid: uid,
      user: {
        uid: uid,
        name: userData.fullName || userData.name || userData.displayName || userData.sellerName || "",
        phoneNumber: userData.phoneNumber || userData.phone || userData.contactNumber || formattedPhone,
        role: customClaims.role,
      },
    };
  } catch (error) {
    console.error("Error executing customLogin callable function:", error);
    if (error instanceof HttpsErrorV2 || error.code || error.status) {
      throw error;
    }
    throw new HttpsErrorV2(
      "internal",
      `Authentication internal error: ${error.message}`
    );
  }
});
