# Food Delivery App
![Flutter](https://img.shields.io/badge/Flutter-%5E3.11.1-02569B?logo=flutter)
![Dart](https://img.shields.io/badge/Dart-%230175C2.svg?logo=dart&logoColor=white)

A modern and responsive food delivery application built using the Flutter framework.

## Features

*   **Intuitive Onboarding**: A seamless "Get Started" experience featuring high-quality imagery like `chef.png`.
*   **Vector Graphics**: Optimized UI using `flutter_svg` for crisp icons and logos (e.g., `FoodGo.svg`).
*   **Multi-Platform Support**: Built to run seamlessly on Android, iOS, Web, Windows, and Linux.
*   **Modern UI**: Designed with responsiveness in mind to handle various screen sizes.

## Getting Started

### Prerequisites

Before you begin, ensure you have the following installed:
*   Flutter SDK (Version ^3.11.1)
*   Dart SDK
*   An IDE (VS Code, Android Studio, or IntelliJ)

### Installation

1.  **Clone the repository:**
    ```bash
    git clone https://github.com/SRIKUMAR10/food_delivery_app.git
    ```
2.  **Navigate to the project directory:**
    ```bash
    cd food_delivery_app
    ```
3.  **Install dependencies:**
    ```bash
    flutter pub get
    ```
4.  **Run the application:**
    ```bash
    flutter run
    ```

## Project Structure

```text
lib/
├── main.dart             # Entry point of the application
assets/
├── images/               # Image assets (chef, sign up, logos)
test/
└── widget_test.dart      # Smoke tests for onboarding flow
```

## Assets Used

*   `chef.png`: Used in the onboarding screen.
*   `FoodGo.svg`: Primary application branding.
*   `Sign up.png`: UI asset for user registration flow.

## Dependencies

*   `flutter_svg`: For rendering SVG assets like the application logo.
*   `cupertino_icons`: For iOS-style icons.
