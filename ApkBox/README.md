## ApkBox: edit .apk file more easily
===========================

apk.bat		unpack and repack .apk in one call
apktools.bat	wrapper for apktool.jar
signapk.bat	wrapper for signapk.jar
smali_clean.bat	clean some class refer in smali folder


Requirement:
------------

* Download [apktool](https://code.google.com/p/android-apktool/), place _apktool.jar_ and _aapt.exe_ in this folder
* [signapk](https://code.google.com/p/signapk/), place _signapk.jar_, _testkey.pk8_ and _testkey.x509.pem_ in signapk folder
  * if you use another key, adjust signapk.bat


Usage:
------------

* unpack .apk using `apk file-name-without-suffix`
* remove ads, take com.google.ads for example
  * delete file-name-without-suffix/smali/com/google/ads
  * run `smali_clean file-name-without-suffix com.google.ads`
  * take a look at commented lines and the console output
* more editing...
* repack using `apk file-name-without-suffix`
* if packed succ, install out/file-name-without-suffix__bs__.apk and have a test

