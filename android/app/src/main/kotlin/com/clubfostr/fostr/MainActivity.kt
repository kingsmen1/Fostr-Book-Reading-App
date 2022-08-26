package com.clubfostr.fostr

import android.util.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import okhttp3.*
import java.io.IOException
import android.app.NotificationManager;
import android.content.Context;

class MainActivity: FlutterActivity() {

    private val CHANNEL = "com.clubfostr.fostr/channel"
    private val URL = "https://us-central1-fostr2021.cloudfunctions.net/recordingapis/recording/channels/"
    private var recording: Boolean = false
    private var userId: String = ""
    private var roomId: String = ""
    private var resourceId: String = ""
    private var sid: String = ""
    private var uid: String = ""
    private var cname: String = ""
    private var token: String = ""

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
           if(call.method == "setRecordingIDs"){
                val args = call.arguments as Map<String, String>
                userId = args["userId"]!!
                roomId = args["roomId"]!!
                resourceId = args["resourceId"]!!
                sid = args["sid"]!!
                uid = args["uid"]!!
                cname = args["cname"]!!
                token = args["token"]!!
                Log.d("MainActivity", "setRecordingIDs: $userId, $roomId, $resourceId, $sid, $uid, $cname, $token")
                result.success(1)
             }
             else if(call.method == "setRecording"){
                 recording = call.arguments as Boolean
                result.success(1)
             }
           else {
                result.notImplemented()
            }
        }
    }

    override fun onResume(){
        super.onResume()
        closeAllNotifications()
    }

    private fun closeAllNotifications() {
        val notificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        notificationManager.cancelAll()
    }
 
    override fun onDestroy() {
        super.onDestroy()
        if(recording){
            val client = OkHttpClient()
            val url = URL + cname + "/" + uid + "/" + resourceId + "/" + sid + "/stop"
            val body = FormBody.Builder()
                .add("user_id", userId)
                .add("room_id", roomId)
                .add("resource_id", resourceId)
                .add("sid", sid)
                .add("uid", uid)
                .add("cname", cname)
                .add("token", token)
                .build()
            val request = Request.Builder()
                .url(url)
                .post(body)
                .build()
            client.newCall(request).enqueue(object : Callback {
                override fun onFailure(call: Call, e: IOException) {
                    Log.d("MainActivity", "onFailure: " + e.message)
                }

                override fun onResponse(call: Call, response: Response) {
                    Log.d("MainActivity", "onResponse: " )
                }
            })
        }
    }

    

}

