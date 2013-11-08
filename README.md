# Monaca Framework for iOS
***
Welcome to the **Monaca** project. 

**Monaca** is a platform to develop cross-platform, native mobile applications using HTML5.

Currently, **Monaca** supports the development of iOS, Android and  Windows8 Apps.

This repository is a framework for iOS.

By using **Cloud IDE** of **Monaca**, you can develop on the [Web](https://monaca.mobi) without having to download this framework.

***
# Features

### **NativeComponents**
NativeComponents make it possible to create native UI and access them from JavaScript.

You can define UI easily using JSON format. 

**Components:**
- NavigationBar & NavigationBar Item
    - Button
    - BackButton
    - Segment
    - Label
    - SearchBox
-  Tabbar
    - TabBar Item
- Native Screen Transition
    - Transit Animation
    - Page Stack Management

### Support for PhoneGap
You can access device functions from JavaScript using the PhoneGap API in Monaca.

- Accelerometer
- Camera
- Capture
- Compass
- Connection
- Contacts
- Device
- Events
- File
- Geolocation
- Globalization
- InAppBrowser
- Media
- Notification
- Splashscreen
- Storage

### Support for Push Notifications


### Support for Monaca Backend


***

# How to build

### 1. Clone the project
 Run the following command:

        git clone git@github.com:monaca/monaca-framework-ios.git

### 2. Move the project folder
 Run the following command:

        cd monaca-framework-ios

### 3. Import DemoApp
 Run the following command:

        git submodule init
        git submodule update
        cd MonacaSandbox/www
        git checkout MonacaDemo

### 4.  Run App in Xcode 

 Open MonacaFramework.xcodeproj in root directory.

 And Run Xcode by selecting the "sandbox" as the build target.

***

# How to use without Xcode

You can use this framework on Google Chrome or Safari without Xcode.

Go to the [Monaca Web](https://monaca.mobi).

***
# Getting Help

### Documentation
[Monaca Document](https://docs.monaca.mobi/).

### Forum
[Monaca Forum](https://monaca.mobi/forum).

***

# Twitter
[Monaca Twitter](https://twitter.com/monaca_mobi_en).

