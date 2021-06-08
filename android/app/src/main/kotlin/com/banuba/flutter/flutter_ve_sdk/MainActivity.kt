package com.banuba.flutter.flutter_ve_sdk

import android.os.Bundle
import com.banuba.sdk.cameraui.domain.MODE_RECORD_VIDEO
import com.banuba.sdk.ve.flow.VideoCreationActivity
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant

class MainActivity : FlutterActivity() {
    private val CHANNEL = "startActivity/VideoEditorChannel"

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        val appFlutterEngine = requireNotNull(flutterEngine)

        GeneratedPluginRegistrant.registerWith(appFlutterEngine)

        MethodChannel(appFlutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method.equals("StartBanubaVideoEditor")) {
                val requestCode = 1

                startActivityForResult(
                        VideoCreationActivity.buildIntent(
                                context = this,
                                // setup data that will be acceptable during export flow
                                additionalExportData = null,
                                // set TrackData object if you open VideoCreationActivity with preselected music track
                                audioTrackData = null
                        ), requestCode, null
                )
                result.success("ActivityStarted")
            } else {
                result.notImplemented()
            }
        }
    }
}
