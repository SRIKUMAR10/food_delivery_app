importScripts("https://www.gstatic.com/firebasejs/10.7.0/firebase-app-compat.js");
importScripts("https://www.gstatic.com/firebasejs/10.7.0/firebase-messaging-compat.js");

firebase.initializeApp({
  apiKey: "AIzaSyCo2p5qPkTyj2zl3hxVvH1C5B-mN9vOXFs",
  appId: "1:318384112771:web:ad7285a79beb303b4d47b6",
  messagingSenderId: "318384112771",
  projectId: "food-delivery-app-cd4ca",
  authDomain: "food-delivery-app-cd4ca.firebaseapp.com",
  storageBucket: "food-delivery-app-cd4ca.firebasestorage.app",
  measurementId: "G-1CKZMSMETQ"
});

const messaging = firebase.messaging();
