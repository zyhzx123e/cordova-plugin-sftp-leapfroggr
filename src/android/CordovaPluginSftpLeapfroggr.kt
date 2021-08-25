package org.apache.cordova.cordovapluginsftpleapfroggr

import android.R.attr.*
import android.os.AsyncTask
import org.apache.cordova.CordovaPlugin
import org.apache.cordova.CallbackContext

import org.json.JSONArray
import org.json.JSONException
import org.json.JSONObject
import com.jcraft.jsch.ChannelExec
import android.util.Log
import com.jcraft.jsch.ChannelSftp
import com.jcraft.jsch.JSch
import com.jcraft.jsch.SftpProgressMonitor
import java.io.ByteArrayOutputStream
import java.util.*




enum class ActionType(val value: String) {
    CONFIGURE("configSFTP"),
    UPLOAD("upload"),
    COOLMETHOD("coolMethod")
}

internal class SFTPConfig(host: String, username: String, password: String, destination_folder: String?) {
    var host: String = host
    var username: String = username
    var password: String = password
    var destination_folder: String? = destination_folder
}

internal class SFTPFileConfig(localpath: String, destinationpath: String) {
    var localpath: String = localpath
    var destinationpath: String = destinationpath
}

internal class SFTPUploadObject(sftpConfig: SFTPConfig, sftpFileConfig: SFTPFileConfig, callbackContext: CallbackContext){
    var sftpConfig: SFTPConfig = sftpConfig
    var sftpFileConfig: SFTPFileConfig = sftpFileConfig
    var callbackContext: CallbackContext = callbackContext
}

/**
 * This class echoes a string called from JavaScript.
 */
class CordovaPluginSftpLeapfroggr : CordovaPlugin() {

    internal var sftpConfig: SFTPConfig? = null

    @Throws(JSONException::class)
    override fun execute(action: String, args: JSONArray, callbackContext: CallbackContext): Boolean {
        print(action)
        when(action){
            ActionType.COOLMETHOD.value -> {
                val message = args.getString(0)
                this.coolMethod(message, callbackContext)
                return true
            }
            ActionType.CONFIGURE.value -> {
                this.configureSFTP(args.getJSONObject(0))
                return true
            }
            ActionType.UPLOAD.value -> {
                this.upload(args.getJSONObject(0), callbackContext)
                return  true
            }
        }

        return false
    }

    private fun coolMethod(message: String?, callbackContext: CallbackContext) {
        if (message != null && message.length > 0) {
            callbackContext.success(message)
        } else {
            callbackContext.error("Expected one non-empty string argument.")
        }
    }

    private fun configureSFTP(config: JSONObject) {
        Log.d("Configure", config.toString())
        this.sftpConfig = SFTPConfig(config.getString("host"), config.getString("username"), config.getString("password"), config.getString("destination_folder"))

    }


    private fun upload(fileconfig: JSONObject, callbackContext: CallbackContext) {
        if(this.sftpConfig != null){
            val destinationpath = "/"+(this!!.sftpConfig?.destination_folder ?: "root")+"/"+fileconfig.getString("filename")
            val localpath = fileconfig.getString("filepath").replace("file://","")

            val sftpFileConfig = SFTPFileConfig(localpath, destinationpath)
            val sftpUploadObject = SFTPUploadObject(this.sftpConfig!!, sftpFileConfig, callbackContext)

            Log.d("UPLOAD", (this.sftpConfig!!.host +" "+ this.sftpConfig!!.username +" "+ this.sftpConfig!!.password ))

            UploadTask().execute(sftpUploadObject)

        }else{
            callbackContext.error("SFTP not configured")
        }
    }
}


private class UploadTask : AsyncTask<SFTPUploadObject, Integer, Boolean>() {

    override fun doInBackground(vararg params: SFTPUploadObject?): Boolean {

        val uploadObject = params[0]
        val sftpConfig = uploadObject?.sftpConfig
        val sftpFile = uploadObject?.sftpFileConfig

        try {
            val jsch = JSch()

            var session = jsch.getSession(sftpConfig!!.username, sftpConfig!!.host,  22)
            session.setPassword(sftpConfig!!.password)

            val config = Properties()
            config["StrictHostKeyChecking"] = "no"

            session.setConfig(config)
            Log.d("UPLOAD","connecting to host")
            session.connect()
            Log.d("UPLOAD","host connected")

            Log.d("UPLOAD","creating session")
            val channel = session.openChannel("sftp")
            channel.connect()
            Log.d("UPLOAD","session created")
            val channelSftp = channel as ChannelSftp

            Log.d("UPLOAD","uploading")
            channelSftp.put(sftpFile!!.localpath, sftpFile!!.destinationpath, ChannelSftp.OVERWRITE)
            Log.d("UPLOAD","upload complete")

            channelSftp.exit()
            session.disconnect()

            uploadObject!!.callbackContext.success("upload completed")

        } catch (ex: Exception) {
            ex.printStackTrace()
            uploadObject!!.callbackContext.error(ex.message)
            return false
        }


        return true
    }

}