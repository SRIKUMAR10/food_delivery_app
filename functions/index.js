const functions = require("firebase-functions");
const admin = require("firebase-admin");
const Razorpay = require("razorpay");

admin.initializeApp();

// Initialize Razorpay instance
const razorpay = new Razorpay({
  key_id: "rzp_test_Spi5WU6ETE2VVp",
  key_secret: "OPHd1aGIeUTqf5Fysi1ntBOS",
});

exports.createPaymentLink = functions.https.onRequest(async (req, res) => {
  // CORS configuration to allow the Flutter Web app to call this function
  res.set("Access-Control-Allow-Origin", "*");
  res.set("Access-Control-Allow-Methods", "POST, OPTIONS");
  res.set("Access-Control-Allow-Headers", "Content-Type, Authorization");

  // Handle preflight requests for CORS
  if (req.method === "OPTIONS") {
    res.status(204).send("");
    return;
  }

  if (req.method !== "POST") {
    res.status(405).send({ message: "Method Not Allowed" });
    return;
  }

  try {
    // 1. Verify Firebase Authentication ID Token
    const authHeader = req.headers.authorization;
    if (!authHeader || !authHeader.startsWith("Bearer ")) {
      res.status(401).send({ message: "Unauthorized: Missing Authorization header" });
      return;
    }

    const idToken = authHeader.split("Bearer ")[1];
    let decodedToken;
    try {
      decodedToken = await admin.auth().verifyIdToken(idToken);
    } catch (error) {
      console.error("Auth Error:", error);
      res.status(401).send({ message: "Unauthorized: Invalid token" });
      return;
    }

    // 2. Parse request body
    const { amount, currency, email, description } = req.body;
    if (!amount) {
      res.status(400).send({ message: "Bad Request: Missing amount" });
      return;
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
      // The callback URL where Razorpay should redirect the user after payment.
      // This allows the WebView in the Flutter app to detect the URL change and pop automatically.
      callback_url: "https://your-app-domain.com/payment-result",
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

exports.createRazorpayOrder = functions.https.onRequest(async (req, res) => {
  // CORS configuration
  res.set("Access-Control-Allow-Origin", "*");
  res.set("Access-Control-Allow-Methods", "POST, OPTIONS");
  res.set("Access-Control-Allow-Headers", "Content-Type, Authorization");

  // Handle preflight requests for CORS
  if (req.method === "OPTIONS") {
    res.status(204).send("");
    return;
  }

  if (req.method !== "POST") {
    res.status(405).send({ message: "Method Not Allowed" });
    return;
  }

  try {
    const { amount, currency, receipt } = req.body;
    
    if (!amount) {
      res.status(400).send({ message: "Bad Request: Missing amount" });
      return;
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
      key_id: razorpay.key_id
    });
  } catch (error) {
    console.error("Error creating Razorpay order:", error);
    res.status(500).send({ message: "Internal Server Error: " + error.message });
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

