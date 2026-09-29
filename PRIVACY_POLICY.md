# Privacy Policy for False Arcade

**Last Updated / Effective Date:** September 29, 2026  
**Application Name:** False Arcade  
**Package Identifier (Android & iOS):** `com.bertoxic.fluga`  
**Developer / Publisher:** Oraezu  

---

Welcome to **False Arcade** ("the Application", "the App", "we", "us", or "our"), created and published by **Oraezu**. We are committed to protecting your privacy and ensuring a transparent, safe, and privacy-respecting gaming experience.

This Privacy Policy explains how information is handled when you download, install, and play **False Arcade** on Android devices (via Google Play) and iOS/iPadOS devices (via Apple App Store).

False Arcade is built with a **Privacy-First, Offline-Only Architecture**. We do not collect, harvest, transmit, share, or sell your personal data.

---

## 1. Summary of Key Principles

* **No Account Required:** You do not need to register, provide an email address, or create a profile to play.
* **Zero Remote Data Collection:** We do not operate remote game servers, databases, or user telemetry endpoints.
* **No Third-Party Tracking or Ads:** The app contains zero advertising SDKs, zero user tracking libraries, and zero behavioral analytics.
* **100% Local Device Storage:** Your high scores, arcade initials, achievements, and gameplay settings stay exclusively on your device.
* **Fully Compliant:** Designed to satisfy Google Play Developer Policy (Data Safety), Apple App Store Review Guidelines (App Privacy details), GDPR, CCPA/CPRA, and COPPA.

---

## 2. Information We Do NOT Collect

We do not collect, request, access, or store any of the following categories of information:

* **Personal Identifiable Information (PII):** Name, email address, physical address, phone number, government ID, or age.
* **Account Credentials:** Passwords, authentication tokens, or social logins (e.g., Google Sign-In, Sign in with Apple, Facebook).
* **Precise or Approximate Geolocation:** GPS data, cell tower triangulation, or IP-based location tracking.
* **Financial and Payment Information:** Credit/debit card numbers, banking details, or billing addresses. False Arcade does not process in-app purchases or subscriptions.
* **Sensory and Biometric Data:** Camera images, microphone audio, Face ID, Touch ID, or fingerprint data.
* **Device Identifiers for Advertising:** Apple Identifier for Advertisers (IDFA), Google Advertising ID (GAID/AAID), or cross-app tracking identifiers.
* **Contacts, Files, or Photos:** Access to your contact list, photo gallery, media files, or file system outside the application's isolated sandbox.

---

## 3. Information Processed Locally on Your Device

To deliver arcade gameplay features, False Arcade stores a minimal set of non-personal configuration and game-state data strictly within your device's secure local storage (`SharedPreferences` on Android, `NSUserDefaults` / local sandbox on iOS):

1. **Arcade Leaderboard & High Scores:**
   * **Retro Initials:** Up to 3 characters of your choosing (e.g., `AAA`, `VEX`, `SAM`) entered for local high scores.
   * **Game Scores & Level Records:** Numerical scores, level numbers reached, and local timestamps.
2. **Game Progress & Achievements:**
   * Unlocked campaign levels, fever thresholds, challenge criteria, and badge progression.
3. **User Preferences & Gameplay Settings:**
   * Sound effect volume/mute toggles.
   * Chiptune music toggle.
   * Haptic vibration toggle.

> **Guarantee:** This data never leaves your device. It is never transmitted across the internet, never backed up to developer servers, and is completely inaccessible to Oraezu or any third parties.

---

## 4. Device Permissions

False Arcade requests only the bare minimum platform permissions strictly necessary for core tactile feedback:

### Android
* `android.permission.VIBRATE`:
  * **Purpose:** Enables tactile haptic feedback when collisions, edge bounces, score milestones, or arcade fever triggers occur.
  * **Network Access:** False Arcade does **not** request the `android.permission.INTERNET` permission in its manifest. The application cannot establish inbound or outbound internet connections.

### iOS / iPadOS
* **Core Haptics / UI Feedback:**
  * **Purpose:** Uses the device Taptic Engine for subtle vibration feedback during gameplay.
  * **No Sensitive Permissions:** False Arcade does not request permissions for Location, Camera, Microphone, Motion Sensors, Notifications, or App Tracking Transparency (ATT).

---

## 5. Third-Party Services and Software Development Kits (SDKs)

False Arcade uses an entirely self-contained Flutter engine and audited local utility packages (`audioplayers` for chiptune sound synthesis, `shared_preferences` for on-device persistence).

* **No Advertising Networks:** No Google AdMob, Unity Ads, AppLovin, ironSource, or similar ad networks.
* **No Analytics Providers:** No Google Analytics for Firebase, Firebase Crashlytics, Mixpanel, AppsFlyer, or Adjust.
* **No Social Media SDKs:** No Meta/Facebook SDKs, TikTok SDKs, or external trackers.
* **No Cloud Backends:** No Supabase, Firebase Firestore, AWS Amplify, or custom telemetry APIs.

No third-party SDK has access to your device, network, or data through False Arcade.

---

## 6. Data Retention and Deletion (Your Rights)

Because all gameplay data is stored strictly on your local device hardware:

* **Complete Deletion at Any Time:** You can permanently erase all high scores, settings, and achievement data at any time by:
  * **Android:** Opening **Settings** → **Apps** → **False Arcade** → **Storage & Cache** → **Clear Data / Clear Storage**.
  * **iOS:** Deleting the **False Arcade** app from your home screen (removes the app's local sandbox storage completely).
* **Uninstalling the App:** Removing False Arcade from your device instantaneously and permanently purges all local game data.
* **Account Deletion Compliance (Apple Guideline 5.1.1(v) & Google Play):** Because False Arcade does not feature user accounts, profiles, or server storage, no account deletion request workflow is required. Deleting the app or clearing device storage immediately destroys all associated user data.

---

## 7. Children's Privacy (COPPA & Global Standards)

False Arcade is an offline, family-friendly skill arcade game suitable for all audiences:

* We comply fully with the **Children’s Online Privacy Protection Act (COPPA)** in the United States and the **General Data Protection Regulation (GDPR)** in the European Union / United Kingdom.
* We do **not** knowingly collect, solicit, or maintain any personal information from children under the age of 13 (or under 16 in certain EU jurisdictions).
* Because the app does not collect personal data from *any* user, no child data is ever captured, tracked, or transmitted.
* The application does not contain chat rooms, open text fields, user-to-user messaging, or unvetted external web links.

---

## 8. Compliance with Global Privacy Regulations

### European Union & United Kingdom (GDPR / UK GDPR)
* **Legal Basis for Processing:** Processing of local game state is strictly necessary for the performance of the game requested by the user (Article 6(1)(b) GDPR).
* **Data Subject Rights:** Because we do not collect, hold, or process personal data on remote servers or associate data with real-world identities, we have no capability to identify you or access your personal records. You exercise complete right of access, rectification, and erasure directly on your device by resetting or uninstalling the app.

### California Consumer Privacy Act (CCPA) / CPRA
* **Do Not Sell or Share My Personal Information:** We do **not** sell, rent, release, disclose, disseminate, make available, transfer, or otherwise communicate personal information to any third party for monetary or valuable consideration.
* **Non-Discrimination:** We do not discriminate against any user for exercising their privacy rights.

---

## 9. App Store Specific Disclosures

### Google Play Store: Data Safety Section Guide
When submitting or updating False Arcade in the Google Play Console:

| Question | Accurate Answer |
| :--- | :--- |
| **Does your app collect or share any of the required user data types?** | **No** |
| **Is all of the user data collected by your app encrypted in transit?** | **Not Applicable** (no data is collected or transferred) |
| **Do you provide a way for users to request that their data is deleted?** | **Yes** (users delete data by clearing storage or uninstalling the app) |
| **Target Audience** | Safe for all age groups (Zero personal data collected) |

### Apple App Store: App Privacy "Nutrition Labels"
When completing the App Privacy section in App Store Connect:

| Label Category | Accurate Declaration |
| :--- | :--- |
| **Data Collection** | **Data Not Collected** (Check "We do not collect data from this app") |
| **Tracking** | **No Tracking** (App does not track users across other companies' apps or websites) |
| **App Tracking Transparency (ATT)** | **Not Required** (No IDFA requested, no advertising SDKs) |

---

## 10. Developer Contact Information

If you have questions, comments, or concerns regarding this Privacy Policy or the privacy practices of False Arcade, please contact us at:

* **Developer / Publisher:** Oraezu
* **Package Identifier:** `com.bertoxic.fluga`
* **Contact Email:** [support@oraezu.com](mailto:support@oraezu.com)
* **Developer Repository:** [https://github.com/bertoxic/false_arcade](https://github.com/bertoxic/false_arcade)
