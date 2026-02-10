@echo off
echo Replacing app icons with custom logo...

REM Copy applogo.png to Android icon directories
copy "assets\applogo.png" "android\app\src\main\res\mipmap-mdpi\ic_launcher.png" /Y
copy "assets\applogo.png" "android\app\src\main\res\mipmap-hdpi\ic_launcher.png" /Y
copy "assets\applogo.png" "android\app\src\main\res\mipmap-xhdpi\ic_launcher.png" /Y
copy "assets\applogo.png" "android\app\src\main\res\mipmap-xxhdpi\ic_launcher.png" /Y
copy "assets\applogo.png" "android\app\src\main\res\mipmap-xxxhdpi\ic_launcher.png" /Y

REM Copy applogo.png to iOS icon directories
copy "assets\applogo.png" "ios\Runner\Assets.xcassets\AppIcon.appiconset\Icon-App-20x20@1x.png" /Y
copy "assets\applogo.png" "ios\Runner\Assets.xcassets\AppIcon.appiconset\Icon-App-20x20@2x.png" /Y
copy "assets\applogo.png" "ios\Runner\Assets.xcassets\AppIcon.appiconset\Icon-App-20x20@3x.png" /Y
copy "assets\applogo.png" "ios\Runner\Assets.xcassets\AppIcon.appiconset\Icon-App-29x29@1x.png" /Y
copy "assets\applogo.png" "ios\Runner\Assets.xcassets\AppIcon.appiconset\Icon-App-29x29@2x.png" /Y
copy "assets\applogo.png" "ios\Runner\Assets.xcassets\AppIcon.appiconset\Icon-App-29x29@3x.png" /Y
copy "assets\applogo.png" "ios\Runner\Assets.xcassets\AppIcon.appiconset\Icon-App-40x40@1x.png" /Y
copy "assets\applogo.png" "ios\Runner\Assets.xcassets\AppIcon.appiconset\Icon-App-40x40@2x.png" /Y
copy "assets\applogo.png" "ios\Runner\Assets.xcassets\AppIcon.appiconset\Icon-App-40x40@3x.png" /Y
copy "assets\applogo.png" "ios\Runner\Assets.xcassets\AppIcon.appiconset\Icon-App-60x60@2x.png" /Y
copy "assets\applogo.png" "ios\Runner\Assets.xcassets\AppIcon.appiconset\Icon-App-60x60@3x.png" /Y
copy "assets\applogo.png" "ios\Runner\Assets.xcassets\AppIcon.appiconset\Icon-App-76x76@1x.png" /Y
copy "assets\applogo.png" "ios\Runner\Assets.xcassets\AppIcon.appiconset\Icon-App-76x76@2x.png" /Y
copy "assets\applogo.png" "ios\Runner\Assets.xcassets\AppIcon.appiconset\Icon-App-83.5x83.5@2x.png" /Y
copy "assets\applogo.png" "ios\Runner\Assets.xcassets\AppIcon.appiconset\Icon-App-1024x1024@1x.png" /Y

echo App icons replaced successfully!
echo Run 'flutter clean' and 'flutter run' to see the changes.
pause