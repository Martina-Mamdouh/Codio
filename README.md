# Kodio - Smart Deals & Business Discovery App 🚀

**Kodio** is a comprehensive Flutter application designed to connect users with the best deals, student offers, and top-rated companies. It features a robust ecosystem comprising a **Consumer Mobile App** and a powerful **Web Admin Dashboard** for managing content.

---

## 📱 Project Overview

Kodio serves as a bridge between consumers and businesses, providing:
- **Exclusive Deals:** A curated list of new, featured, and expiring offers.
- **Student Focus:** Special section dedicated to student-only discounts.
- **Company Directory:** Detailed profiles with location, social links, and reviews.
- **Smart Filtering:** Prioritized content display (Student > Ending Soon > Featured > New).

## ✨ Key Features

### 🛍️ User App (Mobile)
- **Home Feed:** Dynamic sections with prioritized deal fetching.
- **Student Zone:** Exclusive deals tailored for students.
- **Company Profiles:** View business details, location (Map integration), and social media links.
- **Follow System:** Users can follow their favorite companies to stay updated.
- **Favorites:** Save deals for later.
- **Search:** Powerful search functionality for deals and companies.
- **Responsive Design:** Optimized for various screen sizes using `flutter_screenutil`.

### 🛠️ Admin Dashboard (Web)
- **Dashboard Overview:** Quick stats and management tools.
- **Deals Management:** Create, edit, and delete deals with a "Featured" toggle.
- **Company Management:** Manage business profiles, logos, and covers.
- **Banner Management:** Control the home screen carousel.
- **Category Management:** Organize deals into categories.
- **Review System:** Moderate user reviews.
- **Security:** Supabase-backed authentication for admin access.

---

## 🛠️ Technology Stack

| Category | Technology |
|----------|------------|
| **Framework** | [Flutter](https://flutter.dev/) (Mobile & Web) |
| **Language** | Dart |
| **Backend** | [Supabase](https://supabase.com/) (PostgreSQL + Auth) |
| **State Management** | [Provider](https://pub.dev/packages/provider) |
| **Architecture** | MVVM (Model-View-ViewModel) |
| **UI Utilities** | `flutter_screenutil`, `google_fonts`, `font_awesome_flutter` |

---

## 📂 Project Structure

```
lib/
├── admin/                  # Web Admin Dashboard Code
│   ├── views/              # Admin UI Screens
│   └── viewmodels/         # Admin Logic
├── app/                    # Consumer Mobile App Code
│   ├── views/              # Mobile UI Screens
│   └── viewmodels/         # App Logic
├── core/                   # Shared Resources
│   ├── models/             # Data Models (Deal, Company, etc.)
│   ├── services/           # API Services (Supabase, Auth)
│   └── theme/              # App Branding & Styles
└── main.dart               # Entry Point
```

---

## 🚀 Getting Started

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) installed.
- Valid **Supabase** project with URL and Anon Key.

### Installation

1. **Clone the repository:**
   ```bash
   git clone https://github.com/your-username/kodio.git
   cd kodio
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Configure Environment:**
   Update `lib/core/services/supabase_service.dart` (or your config file) with your Supabase credentials.

4. **Run the App:**

   *   **Mobile App:**
       ```bash
       flutter run
       ```

   *   **Admin Dashboard (Web):**
       ```bash
       flutter run -d chrome -t lib/main_admin.dart --release
       ```

---

## 🎨 UI & Design
The app uses a modern, high-contrast **Lime & Dark** theme for a premium feel.
- **Primary Color:** Electric Lime (#CCFF00)
- **Background:** Dark Onyx (#121212)
- **Typography:** Cairo / Outfit fonts

---

## 🤝 Contributing
1. Fork the project.
2. Create your feature branch (`git checkout -b feature/AmazingFeature`).
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`).
4. Push to the branch (`git push origin feature/AmazingFeature`).
5. Open a Pull Request.

---

Developed with ❤️ by the Kodio Team.
