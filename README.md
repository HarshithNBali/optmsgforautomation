# OptMsg Project

OptMsg App is cross platform mobile application which is developing in flutter framework, this application for public users. There are three application like iOS, Android & Web application. Basically, this is an email communication provider service like user can send, receive the emails to their account. It has search implemented with a loader that shows up before the data has been rendered.

## Getting Started
To begin using this template, following command to get started:

## How to Use 

**Step 1:**

Download or clone this repo by using the link below:

```
git clone https://git.myprojectdesk.com/yogendra-team/OptMsg-app/OptMsg-app.git
```

**Step 2:**

Go to project root and execute the following command in console to get the required dependencies: 

```
flutter pub get 
```

**Step 3:**

```
flutter run
```

**Step 4:**

```
For Android apk : flutter build apk
For IOS : flutter build ios
For WEB : flutter build web
```

### Folder Structure
Here is the core folder structure which flutter provides.

```
flutter-app/
|- android
|- build
|- ios
|- lib
|- test
|- web
```

Here is the folder structure we have been using in this project

```
lib/
|- constants/
|- screens/
|- services/
|- widgets/
|- main.dart
```

Now, lets dive into the lib folder which has the main code for the application.

```
1- Constants - All the application level constants are defined in this directory with-in their respective files. This directory contains the constants for `theme`, `dimentions`, `api endpoints`, `preferences` and `strings`.
2- Screens — Contains all the pages of our project, contains sub directory for each screen.
3- Services — Contains the utilities/common functions of your application.
4- Widgets — Contains the common widgets for your applications. For example, Button, TextField or any re-utilize section etc.
5- Aws - Contains all the media uploading services & configuration.
5- main.dart - This is the starting point of the application. All the application level configurations are defined in this file i.e, theme, routes, title, orientation etc.
```

Flutter 
version  3.27.1
macOS  14.2.1

Tools 
Dart 3.6.0
DevTools 2.40.2


