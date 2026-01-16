package com.example.scam_burst

import android.service.notification.NotificationListenerService
import android.service.notification.StatusBarNotification
import android.content.Intent
import android.util.Log

class NotificationListener : NotificationListenerService() {

    override fun onNotificationPosted(sbn: StatusBarNotification) {
        Log.d("NotificationListener", "onNotificationPosted from=${sbn.packageName}")
        val notification = sbn.notification
        val extras = notification.extras

        val title = extras.getCharSequence("android.title")?.toString()
        val text = extras.getCharSequence("android.text")?.toString()

        val intent = Intent("com.example.scam_burst.NOTIFICATION_LISTENER")
        intent.putExtra("package", sbn.packageName)
        intent.putExtra("title", title)
        intent.putExtra("text", text)
        intent.setPackage(packageName) // 🔥 Ensure broadcast stays within app

        Log.d("NotificationListener", "broadcasting notification title=$title text=$text")
        // Send broadcast with explicit package
        sendBroadcast(intent)
        Log.d("NotificationListener", "broadcast sent successfully")
    }
}
