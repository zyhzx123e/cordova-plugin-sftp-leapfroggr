# cordova-plugin-sftp-leapfroggr-zyh
cordova plugin for sftp 
works on both:
* IOS,
* Android

[Link to Developer](https://github.com/zyhzx123e/)

This is a fork to cordova-plugin-sftp-leapfroggr
added support that upload sftp in IOS since the original only support download sftp in IOS

### Installation

* `cordova plugin add cordova-plugin-sftp-leapfroggr-zyh`

- #### IOS
* uses NMSSH library for sftp operations
* https://github.com/NMSSH/NMSSH
* `pod 'NMSSH'`

- #### Android
* uses JSch library
* http://www.jcraft.com/jsch/
* coded in kotlin
* add library to app gradle
* ``compile group: 'com.jcraft', name: 'jsch', version: '0.1.54'
    compile "org.jetbrains.kotlin:kotlin-stdlib-jdk8:1.2.31"``

### USAGE
