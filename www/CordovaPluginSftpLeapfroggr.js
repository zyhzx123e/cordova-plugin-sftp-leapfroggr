cordova.define("cordova-plugin-sftp-leapfroggr.CordovaPluginSftpLeapfroggr", function(require, exports, module) {
    var exec = require('cordova/exec');
    
    exports.coolMethod = function (arg0, success, error) {
        console.log(arg0)
        exec(success, error, 'CordovaPluginSftpLeapfroggr', 'coolMethod', [arg0]);
    };
    
    exports.configureSFTP = function (arg0, success, error) {
        console.log(arg0)
        exec(success, error, 'CordovaPluginSftpLeapfroggr', 'configSFTP', [arg0]);
    }
    
    exports.upload = function (arg0, success, error) {
        console.log(arg0)
        exec(success, error, 'CordovaPluginSftpLeapfroggr', 'upload', [arg0]);
    }
    
    
    ///////
    //////
    //////
    ///
    
    // function SftpLeapfroggr() {
    //     console.log('sftplea[frogger configureSFTP cstr')
    // }
     
    // SftpLeapfroggr.prototype.coolMethod = function (arg0, success, error) {
    //     console.log(arg0)
    //     exec(success, error, 'CordovaPluginSftpLeapfroggr', 'coolMethod', [arg0]);
    // };
    
    
    // SftpLeapfroggr.prototype.configureSFTP = function (arg0, success, error) {
    //     console.log('sftplea[frogger configureSFTP:')
    //     console.log(arg0)
    //     exec(success, error, 'CordovaPluginSftpLeapfroggr', 'configSFTP', [arg0]);
    // }
    
      
    
    // SftpLeapfroggr.prototype.upload = function (arg0, success, error) {
    //     console.log(arg0)
    //     exec(success, error, 'CordovaPluginSftpLeapfroggr', 'upload', [arg0]);
    // }
     
    // var SftpLeapfroggr = new SftpLeapfroggr();
    // module.exports = SftpLeapfroggr;
     
});
     
