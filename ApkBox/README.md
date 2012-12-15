# ApkBox: edit .apk file more easily

* apk.bat:		unpack and repack .apk in one call
* apktools.bat:		wrapper for apktool.jar
* signapk.bat:		wrapper for signapk.jar
* smali_clean.bat:	clean some class refer in smali folder


Requirement
------------

* have [Java](http://www.java.com/getjava/) installed
* have _zip_ and _unzip_ command support
* Download [apktool](https://code.google.com/p/android-apktool/), place _apktool.jar_ and _aapt.exe_ in this folder
* place signapk stuff _signapk.jar_, _testkey.pk8_ and _testkey.x509.pem_ in _signapk_ folder
  * if you use another CERT, you need adjust _signapk.bat_


Usage
------------

* unpack .apk using `apk file-name-without-suffix`
* remove ads, take com.google.ads for example
  * delete _file-name-without-suffix/smali/com/google/ads_
  * run `smali_clean file-name-without-suffix com.google.ads`
  * take a look at commented lines and the console output
* more editing...
* repack using `apk file-name-without-suffix`
* if packed succ, install _out/file-name-without-suffixbs.apk_ and have a test

