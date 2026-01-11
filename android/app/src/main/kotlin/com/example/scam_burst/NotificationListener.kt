package com.example.scam_burst

import android.app.Notification
import android.content.Intent
import android.service.notification.NotificationListenerService
import android.service.notification.StatusBarNotification
import android.util.Log

class NotificationListener : NotificationListenerService() {
    override fun onNotificationPosted(sbn: StatusBarNotification) {
        super.onNotificationPosted(sbn)
        try {
            Log.d("NotificationListener", "onNotificationPosted from: ${sbn.packageName}")
            val extras = sbn.notification.extras
            val title = extras.getString(Notification.EXTRA_TITLE)
            val text = extras.getCharSequence(Notification.EXTRA_TEXT)?.toString()
            val intent = Intent("com.example.scam_burst.NOTIFICATION_LISTENER")
            intent.putExtra("package", sbn.packageName)
            intent.putExtra("title", title)
            intent.putExtra("text", text)
            Log.d("NotificationListener", "sending broadcast: title=$title text=$text")
            sendBroadcast(intent)
        } catch (e: Exception) {
            // swallow to avoid crashing the service
            e.printStackTrace()
        }
    }

    override fun onNotificationRemoved(sbn: StatusBarNotification) {
        super.onNotificationRemoved(sbn)
    }
}
