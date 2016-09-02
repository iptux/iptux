# ApkBox2: edit .apk file more easily (shell version)

* apk.sh:		unpack and repack .apk in one call
* signapk.sh:		wrapper for signapk.jar
* smali_clean.sh:	clean some class refer in smali folder


Requirement
------------

* have [Java][] installed
* Download [Apktool][], place _apktool.jar_ in _jar_ folder
* Download [smali][], place _baksmali.jar_ and _smali.jar_ in _jar_ folder
* place signapk stuff _signapk.jar_ in _jar_ folder, _testkey.pk8_ and _testkey.x509.pem_ in _security_ folder
    * if you use another CERT, you need modify _signapk.sh_


Usage
------------

* unpack .apk using `./apk.sh file-name.apk`
* remove ads, take com.google.ads for example
  * delete _file-name/smali/com/google/ads_
  * run `./smali_clean.sh file-name com.google.ads`
  * take a look at commented lines and the console output
* more editing...
* repack using `./apk.sh file-name`
* if packed succ, install _out/file-name-debug.apk_ and have a test

[Java]: https://www.java.com/getjava/
[Apktool]: https://bitbucket.org/iBotPeaches/apktool/downloads
[smali]: https://bitbucket.org/JesusFreke/smali/downloads
