# Privacy Policy for False Arcade

**Last Updated / Effective Date:** September 29, 2026  
**Application Name:** False Arcade  
**Package Identifier (Android & iOS):** `com.bertoxic.fluga`  
**Developer / Publisher:** Oraezu  

---

## 1. Overview
False Arcade is a skill-based arcade mobile application created and published by independent developer **Oraezu** ("we", "us", or "our"). 

We do not require user account registration, email logins, or cloud profiles. Core gameplay progression, local scores, and preferences are stored directly on your physical hardware. The application displays advertisements powered by **Google AdMob** to support ongoing maintenance and feature development.

This Privacy Policy explains how data is handled across Android and iOS/iPadOS platforms in accordance with the **Google Play Developer Policy (Data Safety)** and **Apple App Store Review Guidelines (App Privacy details)**.

---

## 2. Information Handled by False Arcade

### A. Information We Do NOT Collect
False Arcade does not directly collect, request, or record personal user information:
* **Personal identifiers:** Names, email addresses, phone numbers, home addresses, or national identification numbers.
* **Account credentials:** Passwords, authentication keys, or social logins (Apple, Google, Facebook).
* **Precise GPS location:** Real-time sensor-derived coordinates or physical location points.
* **Financial & payment data:** Bank account details, credit/debit card numbers, or billing info. (False Arcade offers no in-app purchases or paid subscriptions).
* **Sensory hardware:** Camera feeds, microphone recordings, Face ID, or fingerprint data.
* **Device files:** Photo albums, device documents, or address book contacts.

### B. Information Collected Automatically by Google AdMob
To serve in-game advertisements (such as banner, interstitial, or rewarded ads), False Arcade integrates the **Google Mobile Ads SDK (Google AdMob)**. Google AdMob may collect and process:
* **Device and Advertising Identifiers:** Google Advertising ID (GAID / AAID on Android), Identifier for Advertisers (IDFA on iOS, subject to your explicit tracking permission), or vendor identifiers (IDFV).
* **Coarse Geolocation:** General geographic location (country, state, or city level) derived from IP address to deliver regionally relevant advertising.
* **Ad Interaction Data:** Ad impressions, views, clicks, interaction timestamps, and video playback completion.
* **Diagnostic & Technical Information:** Device make and model, operating system version, network connection type (Wi-Fi or cellular), carrier, and app crash logs related to ad delivery.

---

## 3. Data Processed Locally on Your Device
To maintain your game progress between sessions without requiring an account, False Arcade saves non-personal game data directly to your device (`SharedPreferences` on Android, `NSUserDefaults` on iOS):
* **Hall of Fame:** Up to 3 retro arcade initials of your choice (e.g. `AAA`, `VEX`, `SAM`), high scores, and local timestamps.
* **Progression:** Unlocked campaign tiers and achievement badges.
* **Settings:** Sound effect volume, music toggle, and haptic feedback preferences.

> **Local Storage Guarantee:** All gameplay data remains strictly on your device. We do not transmit gameplay data to our own remote servers.

---

## 4. Third-Party Advertising: Google AdMob
We partner with **Google LLC** ("Google AdMob") to serve ads in False Arcade. Depending on your region, device settings, and privacy choices, AdMob may serve:
* **Personalized Advertising:** Ads targeted based on your previous browsing or app activity across different services (subject to user consent in applicable jurisdictions).
* **Non-Personalized (Contextual) Advertising:** Ads based solely on the context of the game and coarse location (derived from IP address), without using cross-app behavioral profiles.

For details on Google’s advertising practices and data handling:
* [Google Privacy Policy](https://policies.google.com/privacy)
* [How Google Uses Information From Sites or Apps That Use Their Services](https://policies.google.com/technologies/ads)
* [Google AdMob Privacy and Security](https://support.google.com/admob/answer/6128543)

---

## 5. Device Permissions

### Android
* `android.permission.INTERNET` — Enables loading and displaying ads from Google AdMob servers.
* `android.permission.ACCESS_NETWORK_STATE` — Allows the Google Mobile Ads SDK to verify network availability before making ad requests.
* `com.google.android.gms.permission.AD_ID` — Standard permission granting access to the Google Advertising ID for ad frequency capping, fraud prevention, and personalized ads (where permitted).
* `android.permission.VIBRATE` — Drives tactile haptic sensations during gameplay collisions and fever triggers.

### iOS / iPadOS
* **App Tracking Transparency (ATT):** When requested on iOS 14.5 or later, Apple's standard tracking prompt (`NSUserTrackingUsageDescription`) will appear. If you choose "Ask App not to Track", Google AdMob will serve non-personalized contextual ads without accessing your IDFA.
* **Taptic Engine:** Provides subtle tactile haptic responses during arcade gameplay.
* **No Sensitive Permissions:** Does not request permissions for Camera, Microphone, Photo Library, Contacts, or GPS Location.

---

## 6. App Store Specific Disclosures

### Google Play Store: Data Safety Section Guide
When completing the Google Play Console Data Safety questionnaire, declare the following:

| Category | Collected | Shared with 3rd Party | Purpose |
| :--- | :--- | :--- | :--- |
| **Approximate Location** | Yes | Yes (Google AdMob) | Advertising, Analytics, Fraud prevention |
| **Device / Advertising ID** | Yes | Yes (Google AdMob) | Advertising, Analytics, Fraud prevention |
| **App Interactions / Ad Views** | Yes | Yes (Google AdMob) | Advertising, Analytics |
| **Diagnostics / Crash Logs** | Yes | Yes (Google AdMob) | Analytics, App performance |
| **Data Encryption in Transit** | **Yes** (All ad data is transferred over HTTPS/TLS) | | |
| **Data Deletion Request** | **Yes** (Advertising ID can be deleted/reset in OS settings; local data erased by app uninstall) | | |

### Apple App Store: App Privacy "Nutrition Labels"
When completing the App Privacy section in App Store Connect:

| Category | Data Type | Linked to You | Tracking |
| :--- | :--- | :--- | :--- |
| **Identifiers** | Device ID (IDFA / IDFV) | Yes (if ATT permission granted) | Used to track (if user grants ATT consent) |
| **Usage Data** | Product Interaction, Advertising Data | Yes (via AdMob) | No |
| **Location** | Coarse / Approximate Location | No | No |
| **Diagnostics** | Crash & Performance Data | No | No |

---

## 7. User Privacy Controls & Ad Opt-Out

### Android
* Go to **Settings → Google → Ads** (or **Settings → Privacy → Ads**).
* Tap **Delete advertising ID** to permanently remove your device ad identifier, or tap **Reset advertising ID** to wipe past ad history.

### iOS (iPhone & iPad)
* Choose **"Ask App not to Track"** when the App Tracking Transparency dialog appears upon launch.
* Modify this anytime in **Settings → Privacy & Security → Tracking** by toggling False Arcade off.

### European Economic Area (EEA) & United Kingdom (GDPR)
For users in the EEA and UK, False Arcade displays an in-app consent form (Google User Messaging Platform / UMP) allowing you to consent to, customize, or decline personalized advertising and cookie/device identifier use.

### California Residents (CCPA / CPRA)
You have the right to opt out of the "sale" or "sharing" of personal data for cross-context behavioral advertising. You can exercise this right via the device ad settings described above or through the in-app consent preferences.

---

## 8. Data Retention and Deletion
* **Local Game Data:** Stored on your physical device until you clear app storage via OS settings (**Settings → Apps → False Arcade → Clear Storage**) or uninstall the application. Uninstalling removes 100% of saved scores, initials, and settings.
* **Advertising Data:** Managed by Google according to [Google's Data Retention Schedules](https://policies.google.com/technologies/retention).

---

## 9. Children's Privacy (COPPA & Global Standards)
False Arcade complies with the **Children's Online Privacy Protection Act (COPPA)** and the **General Data Protection Regulation (GDPR)**.
* We do not knowingly collect personal data from children under 13 (or under 16 in the EEA).
* For audiences identified as children, Google Mobile Ads SDK is configured with the `tagForChildDirectedTreatment` parameter, disabling personalized interest-based ads and tracking.

---

## 10. Global Regulatory Compliance
* **GDPR / UK GDPR:** Legal basis for local data is contract execution (Art. 6(1)(b) GDPR); legal basis for personalized ads is consent (Art. 6(1)(a) GDPR); for contextual ads/fraud prevention, legitimate interest (Art. 6(1)(f) GDPR).
* **CCPA / CPRA:** You have the right to request information, opt out of advertising data sharing, and enjoy equal service without discrimination.

---

## 11. Contact Information
For any questions regarding this Privacy Policy or False Arcade, please contact:

* **Developer:** Oraezu
* **Application:** False Arcade
* **Package Identifier:** `com.bertoxic.fluga`
* **Support Email:** [support@oraezu.com](mailto:support@oraezu.com)
* **Code Repository:** [https://github.com/bertoxic/false_arcade](https://github.com/bertoxic/false_arcade)
