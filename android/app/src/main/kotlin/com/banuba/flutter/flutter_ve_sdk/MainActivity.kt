package com.banuba.flutter.flutter_ve_sdk

import android.app.Activity
import android.content.Intent
import android.net.Uri
import android.os.Bundle
import com.banuba.sdk.cameraui.data.PipConfig
import com.banuba.sdk.export.data.ExportResult
import com.banuba.sdk.export.utils.EXTRA_EXPORTED_SUCCESS
import com.banuba.sdk.ve.flow.VideoCreationActivity
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant

class MainActivity : FlutterActivity() {

    companion object {
        private const val VIDEO_EDITOR_REQUEST_CODE = 7788
    }

    private val CHANNEL = "startActivity/VideoEditorChannel"

    private lateinit var _result: MethodChannel.Result

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        val appFlutterEngine = requireNotNull(flutterEngine)

        GeneratedPluginRegistrant.registerWith(appFlutterEngine)

        MethodChannel(
            appFlutterEngine.dartExecutor.binaryMessenger,
            CHANNEL
        ).setMethodCallHandler { call, result ->
            if (call.method.equals("StartBanubaVideoEditor")) {
                _result = result
                startActivityForResult(
                    VideoCreationActivity.startFromCamera(
                        context = this,
                        // setup data that will be acceptable during export flow
                        additionalExportData = null,
                        // set TrackData object if you open VideoCreationActivity with preselected music track
                        audioTrackData = null,
                        // set PiP video configuration
                        pictureInPictureConfig = PipConfig(
                            video = Uri.EMPTY,
                            openPipSettings = false
                        )
                    ), VIDEO_EDITOR_REQUEST_CODE
                )
            } else {
                result.notImplemented()
            }
        }
    }

    override fun onActivityResult(requestCode: Int, result: Int, intent: Intent?) {
        if (requestCode == VIDEO_EDITOR_REQUEST_CODE) {
            val exportedVideoResult = if (result == Activity.RESULT_OK) {
                intent?.getParcelableExtra(EXTRA_EXPORTED_SUCCESS) as? ExportResult.Success
            } else {
                ExportResult.Inactive
            }
            _result.success(exportedVideoResult.toString())
        } else {
            _result.success(null)
            return super.onActivityResult(requestCode, result, intent)
        }
    }
}
