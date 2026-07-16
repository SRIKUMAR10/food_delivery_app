const functions = require("firebase-functions");
const admin = require("firebase-admin");
const Razorpay = require("razorpay");
const cors = require("cors");
const crypto = require("crypto");

admin.initializeApp();

// Use Firebase Environment Configuration for sensitive keys
const rzpKeyId = functions.config().razorpay ? functions.config().razorpay.key_id : process.env.RAZORPAY_KEY_ID;
const rzpKeySecret = functions.config().razorpay ? functions.config().razorpay.key_secret : process.env.RAZORPAY_KEY_SECRET;
const rzpWebhookSecret = functions.config().razorpay ? functions.config().razorpay.webhook_secret : process.env.RAZORPAY_WEBHOOK_SECRET;

// Initialize Razorpay instance
const razorpay = new Razorpay({
  key_id: rzpKeyId,
  key_secret: rzpKeySecret,
});

// Configure CORS to only allow the production Firebase Hosting domain
// Deriving project ID from Firebase config or environment to set the domains
const projectId = process.env.GCLOUD_PROJECT || "food-delivery-app-cd4ca";
const allowedOrigins = [
  `https://${projectId}.web.app`,
  `https://${projectId}.firebaseapp.com`
];

const corsHandler = cors({
  origin: function (origin, callback) {
    // Allow requests with no origin (like mobile apps) or allowed origins
    if (!origin || allowedOrigins.indexOf(origin) !== -1) {
      callback(null, true);
    } else {
      callback(new Error('Not allowed by CORS'));
    }
  }
});

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

// Order Status Notifications
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
        break;
      case "Ready":
        if (riderId) targetUids.push(riderId);
        title = "Order Ready";
        body = `Your order is ready for delivery.`;
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
        break;
    }

    if (targetUids.length === 0) return null;

    const tokens = [];
    const db = admin.firestore();
    
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
      // Using sendToDevice which is legacy but widely used in existing setups. 
      // In newer SDKs, sendEachForMulticast is preferred. 
      const response = await admin.messaging().sendToDevice(tokens, payload);
      console.log("Successfully sent messages:", response.successCount);
      
      // Token cleanup
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

// --- Secure Checkout ---
exports.createSecureOrder = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'User must be logged in.');
  }

  const uid = context.auth.uid;
  const { selectedCartItems, customerName, deliveryAddress, paymentMethod } = data;

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
        const price = productData.price || 0;

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

        itemsBySeller[sellerId].totalAmount += (price * item.quantity);
        itemsBySeller[sellerId].items.push({
          id: item.id,
          productId: item.id,
          name: productData.name,
          price: price,
          quantity: item.quantity,
          sellerId: sellerId,
          image: productData.imageUrls && productData.imageUrls.length > 0 ? productData.imageUrls[0] : (productData.imageUrl || null),
          imageUrl: productData.imageUrls && productData.imageUrls.length > 0 ? productData.imageUrls[0] : (productData.imageUrl || null)
        });
      }

      // 3. Perform Writes
      for (const sellerId in itemsBySeller) {
        const orderData = itemsBySeller[sellerId];
        const orderRef = db.collection('orders').doc();
        transaction.set(orderRef, {
          customerId: uid,
          customerName: customerName || 'Unknown Customer',
          sellerId: sellerId,
          status: 'New',
          amount: orderData.totalAmount,
          timestamp: admin.firestore.FieldValue.serverTimestamp(),
          items: orderData.items,
          deliveryAddress: deliveryAddress || 'Default Address',
          paymentMethod: paymentMethod || 'Wallet'
        });
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
