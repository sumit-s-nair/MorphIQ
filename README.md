
# MorphIQ - Form Creator App

**MorphIQ** is a modern, responsive, and feature-rich form creation app designed to simplify the process of building customizable forms. Whether you need forms for surveys, polls, or feedback, MorphIQ empowers you with an intuitive interface, dynamic field options, and seamless Firebase integration.  

## 🚀 Live Demo  
Explore the app live at [https://morph-iq.vercel.app/](https://morph-iq.vercel.app/)  

---

## 📜 Features  
- **Form Builder:** Create customizable forms with multiple input types (text, MCQ, multi-select, date, and number).  
- **Reorderable Fields:** Easily rearrange fields with drag-and-drop functionality.  
- **Dynamic Options:** Add or edit options dynamically for multiple-choice and multi-select fields.  
- **Responsive Design:** Designed for both desktop and mobile platforms.  
- **Firebase Integration:** Secure authentication (Google Sign-In) and real-time data storage using Firebase Firestore.  
- **Dark Theme:** Aesthetic dark theme with a pastel color palette.  

---

## 🛠️ Tech Stack  
- **Frontend:** Flutter Web  
- **Backend:** Firebase Firestore  
- **Authentication:** Firebase Authentication (Google Sign-In)  
- **Hosting:** Vercel  

---

## 🛑 Usage & Licensing  
This app is **not for public use** without proper attribution to the developer(s).  
It is licensed under the **Creative Commons Attribution-NonCommercial 4.0 International (CC BY-NC 4.0)**.  

### License Highlights:  
- You **can** use, modify, and distribute the app for **non-commercial purposes** as long as you give appropriate credit to the original creator(s).  
- You **cannot** use the app or its derivatives for commercial purposes without explicit permission.  

For full license terms, see [CC BY-NC 4.0 License](https://creativecommons.org/licenses/by-nc/4.0/).  

---

## 📦 Installation & Build Instructions  

### Prerequisites  
- [Flutter 3.24.5](https://docs.flutter.dev/get-started/install)  
- Firebase account with Firestore and Authentication configured.  
- Google Cloud Project with OAuth 2.0 Client set up.  

### Setup Instructions  

1. **Clone the Repository:**  
   ```bash  
   git clone https://github.com/your-repo/morphiq.git  
   cd morphiq  
   ```  

2. **Install Dependencies:**  
   ```bash  
   flutter pub get  
   ```  

3. **Firebase Setup:**  
   - Add your `google-services.json` (for Android) and `GoogleService-Info.plist` (for iOS) to the `android/app` and `ios/Runner` directories, respectively.  
   - Update your Firebase configuration in the `web/index.html` file for Flutter Web.  

4. **Run the App Locally:**  
   ```bash  
   flutter run -d chrome  
   ```  

5. **Deploy to Vercel:**  
   - Build the app for the web:  
     ```bash  
     flutter build web  
     ```  
   - Deploy the `build/web` directory to Vercel.  

---

## 📧 Contact & Support  
For issues, suggestions, or contributions, feel free to reach out:  

- **Email:** [sumitnair200405@gmail.com](mailto:sumitnair200405@gmail.com)  
- **GitHub:** [sumit-s-nair](https://github.com/sumit-s-nair)  
