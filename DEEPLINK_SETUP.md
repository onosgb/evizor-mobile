# Deep Linking Setup Guide

This app supports deep linking for both Android and iOS platforms.

## Supported Deep Link Formats

### Custom URL Scheme

- Format: `evizor://<path>`
- Example: `evizor://login`, `evizor://reset-password`

### Universal Links (HTTPS)

- Format: `https://evizor.app/<path>`
- Example: `https://evizor.app/login`, `https://evizor.app/reset-password`

## Available Deep Link Routes

### Authentication

- `evizor://login` or `https://evizor.app/login`
- `evizor://signup/personal` or `https://evizor.app/signup/personal`
- `evizor://signup/contact` or `https://evizor.app/signup/contact`
- `evizor://otp` or `https://evizor.app/otp`
- `evizor://forgot-password` or `https://evizor.app/forgot-password`
- `evizor://reset-password` or `https://evizor.app/reset-password`

### Main App

- `evizor://home` or `https://evizor.app/home`
- `evizor://profile` or `https://evizor.app/profile`
- `evizor://notifications` or `https://evizor.app/notifications`
- `evizor://health` or `https://evizor.app/health`

### Consultation Flow

- `evizor://consultation/type` or `https://evizor.app/consultation/type`
- `evizor://consultation/symptoms` or `https://evizor.app/consultation/symptoms`
- `evizor://consultation/upload` or `https://evizor.app/consultation/upload`
- `evizor://consultation/review` or `https://evizor.app/consultation/review`

### History & Settings

- `evizor://history/visits` or `https://evizor.app/history/visits`
- `evizor://history/prescriptions` or `https://evizor.app/history/prescriptions`
- `evizor://settings` or `https://evizor.app/settings`
- `evizor://settings/change-password` or `https://evizor.app/settings/change-password`
- `evizor://settings/privacy` or `https://evizor.app/settings/privacy`

## Platform-Specific Setup

### Android

✅ Already configured in `android/app/src/main/AndroidManifest.xml`

- Custom scheme: `evizor://`
- Universal links: `https://evizor.app`

**Note:** For universal links to work, you need to host an `assetlinks.json` file at:
`https://evizor.app/.well-known/assetlinks.json`

Example `assetlinks.json`:

```json
[
  {
    "relation": ["delegate_permission/common.handle_all_urls"],
    "target": {
      "namespace": "android_app",
      "package_name": "com.evizor.app",
      "sha256_cert_fingerprints": ["YOUR_APP_SHA256_FINGERPRINT"]
    }
  }
]
```

### iOS

✅ Already configured in `ios/Runner/Info.plist`

- Custom scheme: `evizor://`
- Associated domain: `evizor.app`

**Additional Steps Required:**

1. **Xcode Configuration:**

   - Open `ios/Runner.xcworkspace` in Xcode
   - Select the Runner target
   - Go to "Signing & Capabilities"
   - Add "Associated Domains" capability
   - Add: `applinks:evizor.app`

2. **Apple App Site Association File:**
   Host an `apple-app-site-association` file at:
   `https://evizor.app/.well-known/apple-app-site-association`

   Example `apple-app-site-association`:

   ```json
   {
     "applinks": {
       "apps": [],
       "details": [
         {
           "appID": "TEAM_ID.com.evizor.app",
           "paths": ["*"]
         }
       ]
     }
   }
   ```

   Replace `TEAM_ID` with your Apple Developer Team ID.

## Testing Deep Links

### Android

```bash
# Custom scheme
adb shell am start -a android.intent.action.VIEW -d "evizor://login"

# Universal link
adb shell am start -a android.intent.action.VIEW -d "https://evizor.app/login"
```

### iOS

```bash
# Custom scheme
xcrun simctl openurl booted "evizor://login"

# Universal link
xcrun simctl openurl booted "https://evizor.app/login"
```

## Query Parameters

Deep links support query parameters:

- `evizor://reset-password?email=user@example.com`
- `https://evizor.app/reset-password?email=user@example.com`

Access query parameters in your screens:

```dart
final email = GoRouterState.of(context).uri.queryParameters['email'];
```

## Notes

- GoRouter automatically handles deep link routing
- Invalid deep links will show an error page
- Deep links work when the app is closed, in background, or already open
- Make sure to replace `evizor.app` with your actual domain in production
