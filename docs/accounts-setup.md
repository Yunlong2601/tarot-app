# Accounts: what the owner sets up

The code is done (app + backend, tests pass). Sign-in stays **off** until these are done. iOS shows no sign-in until Apple enrollment exists (Apple requires Sign in with Apple next to Google). Console menus change; follow the current Google and Apple help pages.

## 1. Google sign-in (Android first)
1. Upload any build to Play Console first, so Play App Signing exists. Then in Play Console > Test and release > **App integrity** > App signing, copy the **SHA-1 of the app signing key**.
2. Get the **SHA-1 of your upload key** on the Mac (it asks for the keystore password from `~/shentarot-keys/key.properties`):
   ```bash
   keytool -list -v -keystore ~/shentarot-keys/upload-keystore.jks -alias upload | grep SHA1
   ```
3. Go to https://console.cloud.google.com, sign in with yunlong2601@gmail.com, and create a project named `ShenTarot` (or open the one Play created).
4. **Google Auth Platform > Branding** (OAuth consent screen): app name ShenTarot, support email shenyunlongbusiness@gmail.com, privacy policy https://yunlong2601.github.io/shentarot-legal/privacy.html, terms https://yunlong2601.github.io/shentarot-legal/terms.html. Audience: External. Scopes: only `openid` (no email or profile needed). Publish the app (in production) when ready.
5. **Clients > Create client > Android**: package `com.shentech.shentarot`, SHA-1 from step 1. Create a **second Android client** with the SHA-1 from step 2 (for builds you install yourself).
6. **Clients > Create client > Web application**, name `ShenTarot server`. Copy its **Client ID** (ends with `.apps.googleusercontent.com`). This is not a secret.
7. Send me the web Client ID. I then:
   - set it on the server: `npx wrangler secret put GOOGLE_CLIENT_IDS` (or as a var),
   - apply the database change: `npx wrangler d1 migrations apply shentarot --remote`,
   - deploy, and rebuild the app with `--dart-define=GOOGLE_SERVER_CLIENT_ID=<web client id>` (add it to `app/config/live.json`).
8. Only then switch the Play Data safety form to OAuth (see `docs/play-data-safety.md`).

## 2. Sign in with Apple (after Apple enrollment)
1. developer.apple.com > Certificates, Identifiers & Profiles > Identifiers > your App ID (final bundle id) > enable **Sign in with Apple**.
2. Send me the bundle id. I add it to the server (`APPLE_CLIENT_IDS`), enable the capability in Xcode, and build with `--dart-define=APPLE_SIGNIN=true`.
3. Apple also expects token revocation when an account is deleted; that needs a Sign in with Apple **key** (Keys > + > Sign in with Apple). Create it then; I will add revocation before the iOS release.
