# 🚀 Campus Navigator - Premium HUD Experience

[![Flutter](https://img.shields.io/badge/Flutter-v3.9+-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-v3.0+-0175C2?logo=dart&logoColor=white)](https://dart.dev)
[![Firebase](https://img.shields.io/badge/Firebase-Cloud%20Firestore-FFCA28?logo=firebase&logoColor=black)](https://firebase.google.com/)

**Campus Navigator** is a high-fidelity, futuristic navigation assistant designed for students and visitors. It combines a "Premium HUD" aesthetic with reliable mapping and event tracking.

---

## ✨ Key Features

### 🌌 Premium HUD Map
- **Glassmorphic UI:** Frosted glass effect across all information sheets using `BackdropFilter`.
- **Custom Markers:** Neon-accented building markers for clear campus identification.
- **Dynamic Legend:** A categorized color-coded legend for instant building recognition.
- **Google Maps Integration:** Direct deep-linking to Google Maps for turn-by-turn navigation.

### 🏢 Room-Level Guidance
- Precise directions for **Computing**, **Architecture**, **Pharmacy**, and **Central Blocks**.
- **Intuitive Terminology:** "Ground Floor" support for easier level identification.
- **Plain UI List:** A lightning-fast, static room list for quick lookup without distracting animations.

### 📅 Live Events Gallery
- **Floating Glass Cards:** Beautifully designed event cards that fade into view.
- **Admin Control:** Secure login and management for campus organizers.
- **Dynamic Mesh Background:** Subtle, futuristic animated backgrounds (calibrated for performance).

---

## 🛠️ Tech Stack

- **Framework:** [Flutter](https://flutter.dev)
- **Database:** [Cloud Firestore](https://firebase.google.com/docs/firestore) (Live Events)
- **Maps API:** [google_maps_flutter](https://pub.dev/packages/google_maps_flutter)
- **Aesthetics:**
  - `flutter_animate` for single-shot entry effects.
  - `google_fonts` (Outfit) for modern typography.
- **State Management:** `Provider` (Infrastructure ready).

---

## 🚀 Getting Started

1. **Clone the repo:**
   ```bash
   git clone https://github.com/mohammadsahil74808/Campus-Navigator-app.git
   ```
2. **Install dependencies:**
   ```bash
   flutter pub get
   ```
3. **Configure Firebase:**
   - Add your `google-services.json` (Android) and `GoogleService-Info.plist` (iOS).
4. **Run the app:**
   ```bash
   flutter run
   ```

---

## 🎨 Design Philosophy
The app prioritizes **visual excellence** and **perceived performance**. We use a "One-Shot Animation" model where elements fade into view once and remain stable, eliminating the jitter common in mobile navigation apps.

Developed by sahil❤️ for the Campus Community.
