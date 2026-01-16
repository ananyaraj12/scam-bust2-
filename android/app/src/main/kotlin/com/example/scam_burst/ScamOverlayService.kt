package com.example.scam_burst

import android.app.*
import android.content.Intent
import android.graphics.PixelFormat
import android.net.Uri
import android.os.IBinder
import android.view.*
import android.widget.Button
import android.widget.TextView
import androidx.core.app.NotificationCompat
import org.json.JSONArray

data class FamilyMember(val name: String, val phoneNumber: String)

class ScamOverlayService : Service() {

    private lateinit var windowManager: WindowManager
    private var overlayView: View? = null
    private var familyMembers: List<FamilyMember> = emptyList()

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        val msg = intent?.getStringExtra("msg") ?: "Scam Detected"
        val familyMembersJson = intent?.getStringExtra("familyMembers") ?: "[]"

        android.util.Log.d("ScamOverlayService", "onStartCommand msg=$msg, familyMembersJson=$familyMembersJson")

        // Parse family members JSON
        familyMembers = parseFamilyMembers(familyMembersJson)
        android.util.Log.d("ScamOverlayService", "Parsed ${familyMembers.size} family members")

        startForeground(1, createNotification())

        // Remove existing overlay if any
        overlayView?.let {
            try {
                windowManager.removeView(it)
            } catch (e: Exception) {
                android.util.Log.e("ScamOverlayService", "Error removing old overlay: ${e.message}")
            }
        }

        windowManager = getSystemService(WINDOW_SERVICE) as WindowManager
        overlayView = LayoutInflater.from(this)
            .inflate(R.layout.overlay_scam, null)

        overlayView?.findViewById<TextView>(R.id.scamText)?.text = msg

        // Set up button click listeners
        overlayView?.findViewById<Button>(R.id.btnDismiss)?.setOnClickListener {
            android.util.Log.d("ScamOverlayService", "Dismiss button clicked")
            dismissOverlay()
        }

        overlayView?.findViewById<Button>(R.id.btnCallFamily)?.setOnClickListener {
            android.util.Log.d("ScamOverlayService", "Call Family button clicked, members count=${familyMembers.size}")
            handleCallFamily()
        }

        val params = WindowManager.LayoutParams(
            WindowManager.LayoutParams.MATCH_PARENT,
            WindowManager.LayoutParams.WRAP_CONTENT,
            WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY,
            WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE,
            PixelFormat.TRANSLUCENT
        )

        params.gravity = Gravity.TOP
        android.util.Log.d("ScamOverlayService", "adding overlay view")
        windowManager.addView(overlayView, params)

        return START_NOT_STICKY
    }

    private fun parseFamilyMembers(json: String): List<FamilyMember> {
        return try {
            val jsonArray = JSONArray(json)
            val members = mutableListOf<FamilyMember>()
            for (i in 0 until jsonArray.length()) {
                val obj = jsonArray.getJSONObject(i)
                members.add(
                    FamilyMember(
                        name = obj.getString("name"),
                        phoneNumber = obj.getString("phoneNumber")
                    )
                )
            }
            members
        } catch (e: Exception) {
            android.util.Log.e("ScamOverlayService", "Error parsing family members: ${e.message}")
            emptyList()
        }
    }

    private fun handleCallFamily() {
        when {
            familyMembers.isEmpty() -> {
                android.util.Log.w("ScamOverlayService", "No family members configured")
                dismissOverlay()
            }
            familyMembers.size == 1 -> {
                // Single member - call directly
                callFamilyMember(familyMembers[0].phoneNumber)
            }
            else -> {
                // Multiple members - show picker dialog
                showFamilyPicker()
            }
        }
    }

    private fun showFamilyPicker() {
        val memberNames = familyMembers.map { it.name }.toTypedArray()
        
        val dialog = AlertDialog.Builder(this, android.R.style.Theme_Material_Light_Dialog_Alert)
            .setTitle("Contact Family Member")
            .setItems(memberNames) { _, which ->
                val selectedMember = familyMembers[which]
                android.util.Log.d("ScamOverlayService", "Selected: ${selectedMember.name}")
                callFamilyMember(selectedMember.phoneNumber)
            }
            .setNegativeButton("Cancel") { dialog, _ ->
                dialog.dismiss()
            }
            .create()

        // Make dialog show over overlay
        dialog.window?.setType(WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY)
        dialog.show()
    }

    private fun dismissOverlay() {
        overlayView?.let {
            try {
                windowManager.removeView(it)
                overlayView = null
                android.util.Log.d("ScamOverlayService", "Overlay dismissed")
            } catch (e: Exception) {
                android.util.Log.e("ScamOverlayService", "Error dismissing overlay: ${e.message}")
            }
        }
        stopSelf()
    }

    private fun callFamilyMember(phoneNumber: String) {
        try {
            // Use ACTION_DIAL (doesn't require permission, user confirms before calling)
            val dialIntent = Intent(Intent.ACTION_DIAL).apply {
                data = Uri.parse("tel:$phoneNumber")
                flags = Intent.FLAG_ACTIVITY_NEW_TASK
            }
            startActivity(dialIntent)
            android.util.Log.d("ScamOverlayService", "Dialer opened for $phoneNumber")
            
            // Dismiss overlay after opening dialer
            dismissOverlay()
        } catch (e: Exception) {
            android.util.Log.e("ScamOverlayService", "Error opening dialer: ${e.message}")
        }
    }

    override fun onDestroy() {
        super.onDestroy()
        overlayView?.let {
            try {
                windowManager.removeView(it)
            } catch (e: Exception) {
                android.util.Log.e("ScamOverlayService", "Error in onDestroy: ${e.message}")
            }
        }
    }

    override fun onBind(intent: Intent?): IBinder? = null

    private fun createNotification(): Notification {
        val channelId = "scam_overlay"

        if (android.os.Build.VERSION.SDK_INT >= 26) {
            val channel = NotificationChannel(
                channelId,
                "Scam Overlay",
                NotificationManager.IMPORTANCE_LOW
            )
            getSystemService(NotificationManager::class.java)
                .createNotificationChannel(channel)
        }

        return NotificationCompat.Builder(this, channelId)
            .setContentTitle("Scam Burst Running")
            .setSmallIcon(android.R.drawable.ic_dialog_alert)
            .build()
    }
}
