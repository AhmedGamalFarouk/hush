# Fastlane Setup for Android

This project has been configured with Fastlane for Android deployment. Follow these steps to complete the setup.

## 1. Prerequisites

- **Ruby**: Ensure you have Ruby installed.
- **Bundler**: Install bundler if you haven't: `gem install bundler`

## 2. Install Dependencies

Open a terminal in the `android` directory and run:

```powershell
cd android
bundle install
```

## 3. Google Play Console Setup

To allow Fastlane to upload builds to Google Play, you need a Service Account.

1.  Open the [Google Play Console](https://play.google.com/apps/publish/).
2.  Go to **Setup** > **API access**.
3.  Click **Create new service account**.
4.  Follow the link to the **Google Cloud Platform**.
5.  Click **Create Service Account**.
6.  Name it (e.g., `fastlane-upload`).
7.  Grant it the role **Service Account User**.
8.  Click **Done**.
9.  In the list of service accounts, click the three dots (actions) > **Manage keys**.
10. **Add Key** > **Create new key** > **JSON**.
11. Save the downloaded file as `android/fastlane/pc-api-key.json`.
12. Back in **Google Play Console**, click **Grant Access** for the new service account.
13. Ensure it has **Admin** permissions (or at least Release Manager).

## 4. Signing Configuration

You need to sign your release builds.

1.  Generate a keystore if you don't have one:
    ```powershell
    keytool -genkey -v -keystore upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
    ```
    Move `upload-keystore.jks` to the `android` folder (or keep it somewhere safe and reference it).

2.  Create a file named `key.properties` in the `android` folder with the following content:

    ```properties
    storePassword=your_store_password
    keyPassword=your_key_password
    keyAlias=upload
    storeFile=upload-keystore.jks
    ```

    *Note: `storeFile` path is relative to the `android/app` folder if just a filename, or use an absolute path.*
    *Wait, in the gradle config we used `rootProject.file("key.properties")` but `storeFile` is usually relative to `app` module unless specified otherwise. The gradle edit I made uses `file(it as String)` inside `app/build.gradle.kts`, so it is relative to `android/app/`. So if you put `upload-keystore.jks` in `android/`, you should use `../upload-keystore.jks` or move it to `android/app/`.*
    
    **Recommendation:** Place `upload-keystore.jks` in `android/app/` and use `storeFile=upload-keystore.jks`.

## 5. Run Fastlane

To build and deploy to the Internal track:

```powershell
cd android
bundle exec fastlane deploy
```

## 6. Important Notes

- **Package Name**: Configured as `com.caffeinecode.hush` in `android/fastlane/Appfile`.
- **Application ID**: Configured as `com.caffeinecode.hush` in `android/app/build.gradle.kts`.
- **First Upload**: The first version of your app usually needs to be uploaded manually to the Google Play Console to initialize the application ID and signing keys. Subsequent updates can be done via Fastlane.
