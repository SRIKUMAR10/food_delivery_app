const admin = require('firebase-admin');
const serviceAccount = require('../food-delivery-app-cd4ca-07752283d804.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  storageBucket: 'food-delivery-app-cd4ca.firebasestorage.app'
});

const bucket = admin.storage().bucket();

async function checkStorage() {
  const [files] = await bucket.getFiles({ prefix: 'chat_attachments/' });
  if (files.length === 0) {
    console.log("No files found in chat_attachments/");
    return;
  }
  
  // get the most recent file
  files.sort((a, b) => new Date(b.metadata.timeCreated) - new Date(a.metadata.timeCreated));
  
  const file = files[0];
  console.log("File Name:", file.name);
  console.log("Metadata:");
  console.log(JSON.stringify(file.metadata, null, 2));
  
  // Specifically check for download tokens
  const metadata = file.metadata.metadata || {};
  if (metadata.firebaseStorageDownloadTokens) {
    console.log("Download Token EXISTS:", metadata.firebaseStorageDownloadTokens);
    
    // Construct the download URL
    const url = `https://firebasestorage.googleapis.com/v0/b/${bucket.name}/o/${encodeURIComponent(file.name)}?alt=media&token=${metadata.firebaseStorageDownloadTokens}`;
    console.log("Generated Download URL:", url);
  } else {
    console.log("NO Download Token found in metadata.");
  }
}

checkStorage().catch(console.error);
