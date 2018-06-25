# PasscodeLock
[![Build Status](https://travis-ci.org/zahlz/SwiftPasscodeLock.svg?branch=master)](https://travis-ci.org/zahlz/SwiftPasscodeLock)
[![Swift4.1](https://img.shields.io/badge/swift4.1-compatible-brightgreen.svg)](https://apple.com/ios)
[![Carthage Compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

A Swift implementation of passcode lock for iOS with TouchID authentication.

<center><img src="https://raw.githubusercontent.com/yankodimitrov/SwiftPasscodeLock/master/passcode-lock.gif" height="386"></center>

## Requirements
* iOS 8.0+
* Xcode 9.0+
* Swift 4.1+

## Installation

#### Carthage

Add the following line to your [Cartfile](https://github.com/carthage/carthage)
```swift
github "zahlz/SwiftPasscodeLock"
```
## Usage

1. Create an implementation of the `PasscodeRepositoryType` protocol.

2. Create an implementation of the `PasscodeLockConfigurationType` protocol and set your preferred passcode lock configuration options. If you set the `maximumInccorectPasscodeAttempts` to a number greather than zero when the user reaches that number of incorrect passcode attempts a notification with name `PasscodeLockIncorrectPasscodeNotification` will be posted on the default `NotificationCenter`. 

3. Create an instance of the `PasscodeLockPresenter` class. Next inside your `UIApplicationDelegate` implementation call it to present the passcode in `didFinishLaunchingWithOptions` and `applicationDidEnterBackground` methods. The passcode lock will be presented only if your user has set a passcode.

4. Allow your users to set a passcode by presenting the `PasscodeLockViewController` in `.set` state:

```swift
let configuration = ... // your implementation of the PasscodeLockConfigurationType protocol

let passcodeVC = PasscodeLockViewController(state: .set, configuration: configuration)

presentViewController(passcodeVC, animated: true, completion: nil)
```

You can present the `PasscodeLockViewController` in one of the four initial states using the `LockState` enumeration options: `.enter`, `.set`, `.change`, `.remove`.

Also you can set the initial passcode lock state to your own implementation of the `PasscodeLockStateType` protocol.

## Customization

#### Custom Design

The PasscodeLock will look for `PasscodeLockView.xib` inside your app bundle and if it can't find it will load its default one, so if you want to have a custom design create a new `xib` with the name `PasscodeLockView` and set its owner to an instance of `PasscodeLockViewController` class and module to `PasscodeLock`. 

Then connect the `view` outlet to the view of your `xib` file and make sure to connect the remaining `IBOutlet`s and `IBAction`s. Also make sure to set module to `PasscodeLock` on all `PasscodeSignPlaceholderView` and `PasscodeSignButton` in the nib.

PasscodeLock comes with two view components: `PasscodeSignPlaceholderView` and `PasscodeSignButton` that you can use to create your own custom designs. Both classes are `@IBDesignable` and `@IBInspectable`, so you can see their appearance and change their properties right inside the interface builder:

<center><img src="https://raw.githubusercontent.com/yankodimitrov/SwiftPasscodeLock/master/passcode-view.png" height="270"></center>

#### Localization

Take a look at `PasscodeLock/en.lproj/PasscodeLock.strings` for the localization keys. Here again the PasscodeLock will look for the `PasscodeLock.strings` file inside your app bundle and if it can't find it will use the default localization file.

## Demo App

The demo app comes with a simple implementation of the `PasscodeRepositoryType` protocol that is using the **UserDefaults** to store an retrieve the passcode. In your real applications you will probably want to use the **Keychain API**. Keep in mind that the **Keychain** records will not be removed when your user deletes your app.
