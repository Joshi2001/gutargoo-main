package com.gutargoo.gutrgoopro

import android.app.PictureInPictureParams
import android.os.Build
import android.os.Bundle
import android.util.Rational
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {

    private val CHANNEL = "pip_channel"

    override fun configureFlutterEngine(flutterEngine: io.flutter.embedding.engine.FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                if (call.method == "enterPip") {
                    val entered = enterPipMode()
                    result.success(entered) // ✅ true/false return karo
                } else {
                    result.notImplemented()
                }
            }
    }

    private fun enterPipMode(): Boolean {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            try {
                val aspectRatio = Rational(16, 9)
                val pipBuilder = PictureInPictureParams.Builder()
                pipBuilder.setAspectRatio(aspectRatio)
                enterPictureInPictureMode(pipBuilder.build())
                true
            } catch (e: Exception) {
                false
            }
        } else {
            false // Android O se purana device, PiP nahi
        }
    }
}