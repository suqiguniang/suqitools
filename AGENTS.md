# SuXiaoBox Agent Guide

## Project Structure

```
SuXiaoBox/
├── src/
│   ├── components/       # React components
│   │   ├── CardItem.tsx     # Card item component
│   │   └── AddCardModal.tsx # Add card modal
│   ├── screens/          # Screen components
│   │   ├── HomeScreen.tsx    # Main screen with cards
│   │   ├── WebViewScreen.tsx # WebView screen
│   │   └── SettingsScreen.tsx # Settings screen
│   ├── types.ts          # TypeScript types
│   ├── storage.ts        # AsyncStorage utilities
│   └── wol.ts            # Wake-on-LAN utility
├── android/              # Android native code
│   └── app/src/main/
│       ├── java/com/suxiaobox/widget/  # Widget code
│       └── res/                      # Android resources
├── App.tsx               # Main app component
└── package.json

```

## Key Features

1. **Navigation Cards**: Users can add web links or WOL shortcuts
2. **WOL (Wake-on-LAN)**: Sends magic packets via UDP broadcast
3. **Android Widget**: Home screen widget for quick access
4. **GitHub Actions**: Automated Android APK builds

## Build Commands

```bash
npm install
npx react-native run-android        # Debug build
cd android && ./gradlew assembleRelease  # Release build
```

## Dependencies

- @react-navigation/native
- @react-navigation/stack
- @react-navigation/bottom-tabs
- react-native-webview
- react-native-vector-icons
- @react-native-async-storage/async-storage
- react-native-udp