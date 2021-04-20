# ChopChop

![ChopChop](ChopChop/Assets.xcassets/AppIcon.appiconset/chopchop-60@3x.png)

ChopChop is an application on the iPad for people who cook. It comes with features such as smart recipes, recipe management and ingredient inventory tracking.

## Requirements

* Xcode 12.3
* [Swiftlint 0.43.0](https://github.com/realm/SwiftLint)
* [XcodeGen 2.19.0](https://github.com/yonaskolb/XcodeGen)

## Setup

After installing all dependencies, run XcodeGen to generate the Xcode project.

```bash
git clone https://github.com/cs3217-chopchop/ChopChop.git
cd ChopChop
xcodegen
```

Set up Firebase:
* Create a Firebase project [here](https://console.firebase.google.com/).
* Add an iOS app. Enter your app's bundle ID in the iOS bundle ID field when prompted.
* Download and place the provided `GoogleService-Info.plist` in the main `ChopChop` directory (the directory containing the `Info.plist` file).
* On the Firebase console, enable Firestore and Storage. Setup security rules for both Firestore and Storage.

Refer to [official website](https://firebase.google.com/docs/ios/setup) for any issues.

> Note: A valid `GoogleService-Info.plist` file is necessary to run the app.
