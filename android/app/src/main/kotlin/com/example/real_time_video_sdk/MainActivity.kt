package com.example.real_time_video_sdk

import android.Manifest
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.provider.Settings
import android.view.WindowManager
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant

class MainActivity : FlutterActivity() {
    private val SCREEN_CAPTURE_REQUEST_CODE = 1001
    private var pendingResult: MethodChannel.Result? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        // Prevent screenshots and screen recording
        window.addFlags(WindowManager.LayoutParams.FLAG_SECURE)
        super.configureFlutterEngine(flutterEngine)
        GeneratedPluginRegistrant.registerWith(flutterEngine)
        
        // Setup method channel for screen capture permission
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "com.example.real_time_video_sdk/permissions").setMethodCallHandler { call, result ->
            when (call.method) {
                "checkScreenCapturePermission" -> checkScreenCapturePermission(result)
                "requestScreenCapturePermission" -> {
                    pendingResult = result
                    requestScreenCapturePermission()
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun checkScreenCapturePermission(result: MethodChannel.Result) {
        val hasPermission = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            Settings.canDrawOverlays(this)
        } else {
            true
        }
        result.success(hasPermission)
    }

    private fun requestScreenCapturePermission() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            if (Settings.canDrawOverlays(this)) {
                pendingResult?.success(true)
                pendingResult = null
            } else {
                val intent = Intent(
                    Settings.ACTION_MANAGE_OVERLAY_PERMISSION,
                    Uri.parse("package:$packageName")
                )
                startActivityForResult(intent, SCREEN_CAPTURE_REQUEST_CODE)
            }
        } else {
            pendingResult?.success(true)
            pendingResult = null
        }
    }
    
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode == SCREEN_CAPTURE_REQUEST_CODE) {
            val hasPermission = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                Settings.canDrawOverlays(this)
            } else {
                true
            }
            pendingResult?.success(hasPermission)
            pendingResult = null
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        // Keep screen on during calls
        window.addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)
        
        // Request necessary permissions
        requestRequiredPermissions()
    }

    private fun requestRequiredPermissions() {
        val requiredPermissions = listOf(
            Manifest.permission.CAMERA,
            Manifest.permission.RECORD_AUDIO,
            Manifest.permission.MODIFY_AUDIO_SETTINGS,
            Manifest.permission.INTERNET,
            Manifest.permission.ACCESS_NETWORK_STATE,
            Manifest.permission.ACCESS_WIFI_STATE
        )

        val dangerousPermissions = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            listOf(
                Manifest.permission.SYSTEM_ALERT_WINDOW,
                Manifest.permission.FOREGROUND_SERVICE,
                Manifest.permission.FOREGROUND_SERVICE_MEDIA_PROJECTION
            )
        } else {
            emptyList()
        }

        val allPermissions = (requiredPermissions + dangerousPermissions).toTypedArray()
        val permissionsToRequest = allPermissions.filter {
            ContextCompat.checkSelfPermission(this, it) != PackageManager.PERMISSION_GRANTED
        }.toTypedArray()

        if (permissionsToRequest.isNotEmpty()) {
            ActivityCompat.requestPermissions(
                this,
                permissionsToRequest,
                0
            )
        }
    }
}
