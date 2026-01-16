package com.example.scam_burst

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    private var receiver: BroadcastReceiver? = null
    private var eventSink: EventChannel.EventSink? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        /* ---------------- NOTIFICATION EVENT CHANNEL ---------------- */
        EventChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "com.example.scam_burst/notifications"
        ).setStreamHandler(object : EventChannel.StreamHandler {

            override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                android.util.Log.wtf("MainActivity", "🔥🔥🔥 EventChannel onListen TRIGGERED! events=$events")
                android.util.Log.d("MainActivity", "EventChannel onListen called, events=$events")
                
                // Store the event sink for later use
                eventSink = events
                android.util.Log.d("MainActivity", "EventSink stored, ready to receive broadcasts")
            }

            override fun onCancel(arguments: Any?) {
                android.util.Log.d("MainActivity", "EventChannel onCancel called")
                eventSink = null
            }
        })

        // 🔥 Register receiver IMMEDIATELY, not in onListen
        receiver = object : BroadcastReceiver() {
            override fun onReceive(context: Context?, intent: Intent?) {
                if (intent == null) return

                val pkg = intent.getStringExtra("package")
                val title = intent.getStringExtra("title")
                val text = intent.getStringExtra("text")

                android.util.Log.d("MainActivity", "🎯 BroadcastReceiver.onReceive called! pkg=$pkg title=$title text=$text")

                val map: MutableMap<String, String?> = HashMap()
                map["package"] = pkg
                map["title"] = title
                map["text"] = text

                android.util.Log.d("MainActivity", "forwarding to Flutter eventSink=$eventSink, map=$map")
                eventSink?.success(map)
                android.util.Log.d("MainActivity", "forwarded successfully")
            }
        }

        val filter = IntentFilter("com.example.scam_burst.NOTIFICATION_LISTENER")

        // 🔥 ANDROID 13+ FIX
        if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.TIRAMISU) {
            android.util.Log.d("MainActivity", "registering receiver IMMEDIATELY (RECEIVER_NOT_EXPORTED)")
            registerReceiver(
                receiver,
                filter,
                Context.RECEIVER_NOT_EXPORTED
            )
        } else {
            android.util.Log.d("MainActivity", "registering receiver IMMEDIATELY (legacy)")
            registerReceiver(receiver, filter)
        }

        /* ---------------- NOTIFICATION SETTINGS METHOD CHANNEL ---------------- */
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "com.example.scam_burst/notifications_method"
        ).setMethodCallHandler { call, result ->
            if (call.method == "openNotificationSettings") {
                val intent =
                    Intent(Settings.ACTION_NOTIFICATION_LISTENER_SETTINGS)
                intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                startActivity(intent)
                result.success(null)
            } else {
                result.notImplemented()
            }
        }

        /* ---------------- OVERLAY METHOD CHANNEL ---------------- */
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "scam_overlay"
        ).setMethodCallHandler { call, result ->
            if (call.method == "showOverlay") {
                val msg = call.argument<String>("msg") ?: "Scam Detected"
                val familyMembers = call.argument<String>("familyMembers") ?: "[]"

                // Check overlay permission first
                val hasOverlay = if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.M) {
                    android.provider.Settings.canDrawOverlays(this)
                } else {
                    true
                }

                if (!hasOverlay) {
                    android.util.Log.w("MainActivity", "Overlay permission not granted")
                    result.success(false)
                } else {
                    val intent = Intent(this, ScamOverlayService::class.java)
                    intent.putExtra("msg", msg)
                    intent.putExtra("familyMembers", familyMembers)
                    startForegroundService(intent)
                    android.util.Log.d("MainActivity", "Started ScamOverlayService with msg=$msg, familyMembers=$familyMembers")
                    result.success(true)
                }
            } else if (call.method == "openOverlaySettings") {
                // Open the Android overlay permission screen for this app
                val intent = Intent(android.provider.Settings.ACTION_MANAGE_OVERLAY_PERMISSION)
                intent.data = android.net.Uri.parse("package:$packageName")
                intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                startActivity(intent)
                result.success(true)
            } else {
                result.notImplemented()
            }
        }
    }

    override fun onDestroy() {
        super.onDestroy()
        receiver?.let {
            android.util.Log.d("MainActivity", "Unregistering broadcast receiver")
            unregisterReceiver(it)
        }
        receiver = null
        eventSink = null
    }
}
