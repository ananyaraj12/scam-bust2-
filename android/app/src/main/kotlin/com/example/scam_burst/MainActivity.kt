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

	override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
		super.configureFlutterEngine(flutterEngine)

		// EventChannel to stream notification events to Dart
		EventChannel(flutterEngine.dartExecutor.binaryMessenger, "com.example.scam_burst/notifications")
			.setStreamHandler(object : EventChannel.StreamHandler {
				override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
					receiver = object : BroadcastReceiver() {
						override fun onReceive(context: Context?, intent: Intent?) {
							if (intent == null) return
							val pkg = intent.getStringExtra("package")
							val title = intent.getStringExtra("title")
							val text = intent.getStringExtra("text")
							val map: MutableMap<String, String?> = HashMap()
							map["package"] = pkg
							map["title"] = title
							map["text"] = text
							events?.success(map)
						}
					}
					val filter = IntentFilter("com.example.scam_burst.NOTIFICATION_LISTENER")
					registerReceiver(receiver, filter)
				}

				override fun onCancel(arguments: Any?) {
					receiver?.let { unregisterReceiver(it) }
					receiver = null
				}
			})

		// MethodChannel to open notification access settings
		MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "com.example.scam_burst/notifications_method")
			.setMethodCallHandler { call, result ->
				if (call.method == "openNotificationSettings") {
					val intent = Intent(Settings.ACTION_NOTIFICATION_LISTENER_SETTINGS)
					intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
					startActivity(intent)
					result.success(null)
				} else {
					result.notImplemented()
				}
			}
	}
}
