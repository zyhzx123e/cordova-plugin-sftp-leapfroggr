

/**
 * cordova plugin for IOS
 * - Author: Gabriel Mori Baleta
 * - Important: include NMSHH pod on use of this plugin
 */
@objc(CordovaPluginSftpLeapfroggr) class CordovaPluginSftpLeapfroggr : CDVPlugin {
    
    //: model - SFTPConfig - used to access sftp server
    var sftp_config: SFTPConfig = SFTPConfig()
    
    /**
     * configures sftp info
     */
    @objc(configSFTP:)
    func configureSFTP(command: CDVInvokedUrlCommand) {
        print(command.arguments[0])
        print("configureSFTP swift")
        let config = command.arguments[0] as! Dictionary<String,String>
        self.sftp_config = SFTPConfig(host: config["host"],
                                      username: config["username"],
                                      password: config["password"],
                                      destination_folder: config["destination_folder"])
        let pluginResult = CDVPluginResult (status: CDVCommandStatus_OK, messageAs: "FTP configured...");
        self.commandDelegate!.send(pluginResult, callbackId: command.callbackId);
    }
    
    /**
     * updloads file using NMSFTP
     * calls dispatchQueue uploadFile to run in background thread
     */
    @objc(upload:)
    func upload(command: CDVInvokedUrlCommand) {
        let pluginResult = CDVPluginResult (status: CDVCommandStatus_ERROR, messageAs: "FTP not configured");
        if let fileConfig = command.arguments[0] as? Dictionary<String,String> {
            if((sftp_config.host != nil) && (sftp_config.username != nil) && (sftp_config.password != nil)){
                let filepath = fileConfig["filepath"]!.replacingOccurrences(of: "file://", with: "")+"/"+fileConfig["filename"]!
                let tofilepath = "/\(sftp_config.destination_folder ?? "root")/" + fileConfig["filename"]! //"/\(sftp_config.destination_folder ?? "root")"
                print("uploadFile fileConfig[filename]"+(fileConfig["filename"] ?? ""))
                print("uploadFile tofilepath"+tofilepath)
                let sftpFileConfig = SFTPFileConfig(localpath: filepath, destinationpath: tofilepath)
                DispatchQueue(label: "file upload", qos: .background).async {
                    self.uploadFile(sftp_config: self.sftp_config, sftp_fileconfig: sftpFileConfig, callbackId: command.callbackId)
                }
                return
            }
        }
        self.commandDelegate!.send(pluginResult, callbackId: command.callbackId);
    }
    
    /**
     * sends file to the server
     * - Uses NMSTFTP to upload to the database
     * - Calls commandDelegate on end
     */
    func uploadFile(sftp_config: SFTPConfig, sftp_fileconfig: SFTPFileConfig, callbackId: String){
        var pluginResult = CDVPluginResult (status: CDVCommandStatus_ERROR, messageAs: "can't connect to the server");
        let session = NMSSHSession.init(host: sftp_config.host!, port: 22, andUsername: sftp_config.username!)
        session.connect()
        if session.isConnected{
            print("uploadFile swift connected")
            print("uploadFile swift connected sftp_config")
            print(sftp_config)
            session.authenticate(byPassword: sftp_config.password!)
            pluginResult = CDVPluginResult (status: CDVCommandStatus_ERROR, messageAs: "authentication error");
            
            if session.isAuthorized == true {
                print("uploadFile swift session.isAuthorized == true ")
                let sftpsession = NMSFTP(session: session)
                sftpsession.connect()
                if sftpsession.isConnected {
                    print("uploadFile swift sftpsession isConnected")
                    print("uploadFile swift sftpsession.localpath:"+sftp_fileconfig.localpath)
                    print("uploadFile swift sftpsession.destinationpath:"+sftp_fileconfig.destinationpath)
                    
                    //jason added to create folder if folder not exist
                    let path = sftp_fileconfig.destinationpath
                    let dir = (path as NSString).deletingLastPathComponent
                     if !sftpsession.directoryExists(atPath: dir){
                          print("uploadFile swift sftpsession path not exist now creating:"+dir)
                         sftpsession.createDirectory(atPath: dir)
                     }//Jason added to create folder if folder not exist
                    
                    let response = sftpsession.writeFile(atPath: sftp_fileconfig.localpath, toFileAtPath: sftp_fileconfig.destinationpath) { (progress: UInt) -> Bool in
                        print(progress)
                        return true
                    }
                    if(response){
                        print("uploadFile swift sftp_ uploaded succeeded")
                        pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: "File Upload Completed" );
                    }else{
                        pluginResult = CDVPluginResult (status: CDVCommandStatus_ERROR, messageAs: "File failed to upload");
                    }
                    sftpsession.disconnect()
                }
            }
        }
        self.commandDelegate!.send(pluginResult, callbackId: callbackId);
    }
    
}

//: defines the model of SFTP information needed to connect to the server
struct SFTPConfig {
    var host: String?
    var username: String?
    var password: String?
    var destination_folder: String?
}

/** defines the model of SFTP to be sent to the server
 * @param localpath - string - contains the path of the file from the local storage
 * @param destinationpath - string - contains the path of the file to be stored in the server
 */
struct SFTPFileConfig {
    var localpath: String
    var destinationpath: String
}
