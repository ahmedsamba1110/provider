# eDemand_partner
Version 2.2.0


//To update iOS pods
```shell
cd ios
pod init
pod install
pod update
cd ..
```

//To clean the pub cache 
```shell
flutter clean
flutter pub cache clean
flutter pub get
```

//To repair the pub cache 
```shell
flutter clean
flutter pub cache repair 
y
flutter pub get
```

//to generate android application 
```shell
flutter build apk --split-per-abi
open  build/app/outputs/flutter-apk/
```

// to solve most common iOS errors
```shell
flutter clean
rm -Rf ios/Pods
rm -Rf ios/.symlinks
rm -Rf ios/Flutter/Flutter.framework
rm -Rf Flutter/Flutter.podspec
rm ios/podfile.lock
cd ios 
pod deintegrate
rm -rf ~/Library/Developer/Xcode/DerivedData
flutter pub cache repair
flutter pub get 
Pod update 
pod install 
```

// clean and get the dependency
```shell
flutter clean
flutter pub get
```
