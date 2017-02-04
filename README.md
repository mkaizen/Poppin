# AnyWall

A fun geolocation app built with Parse.

See more details here: https://www.parse.com/anywall

## iOS

### Xcode Project Setup

1. Clone the repository
2. Install all project dependencies from [CocoaPods](http://cocoapods.org/#install) by running this script:
```
cd AnyWall-iOS
pod install
```
3. Open the Xcode workspace at `AnyWall-iOS/AnyWall.xcworkspace`
4. Add your Parse application id and client key in `PAWAppDelegate.m`

#### Configuring Facebook integration

1. Set up a Facebook app at http://developers.facebook.com/apps

2. Set up a URL scheme for fbFACEBOOK_APP_ID, where FACEBOOK_APP_ID is your Facebook app's id.

3. Add your Facebook app id to `Info.plist` in the `FacebookAppID` key.

### Learn More

To learn more, take a look at the [AnyWall iOS](https://parse.com/tutorials/anywall) tutorial.

## Android

### Android Project Setup

1. Clone the repository and import the `Anywall` and `google-play-services_lib` projects from the `AnyWall-android` folder.
2. Add your Parse application id and client key in `Application.java`.
3. Add your Google Maps Android API v2 key in `AndroidManifest.xml`. See the [Google Maps Android API v2 Getting Started guide](https://developers.google.com/maps/documentation/android/start#get_an_android_certificate_and_the_google_maps_api_key) for instructions on how to obtain a key.

### Learn More

To learn more, take a look at the [AnyWall Android](https://www.parse.com/tutorials/anywall-android) tutorial.
