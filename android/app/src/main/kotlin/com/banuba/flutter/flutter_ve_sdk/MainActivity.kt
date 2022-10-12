package com.banuba.flutter.flutter_ve_sdk

import android.app.Activity
import android.content.Intent
import android.net.Uri
import android.os.Bundle
import android.util.Log
import com.banuba.sdk.cameraui.data.PipConfig
import com.banuba.sdk.export.data.ExportResult
import com.banuba.sdk.export.utils.EXTRA_EXPORTED_SUCCESS
import com.banuba.sdk.ve.flow.VideoCreationActivity
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant
import java.io.File

class MainActivity : FlutterActivity() {

    companion object {
        private const val VIDEO_EDITOR_REQUEST_CODE = 7788
        const val TAG = "FlutterVE"
    }

    private val CHANNEL = "startActivity/VideoEditorChannel"

    private lateinit var exportVideoChanelResult: MethodChannel.Result

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        val appFlutterEngine = requireNotNull(flutterEngine)

        GeneratedPluginRegistrant.registerWith(appFlutterEngine)

        MethodChannel(
            appFlutterEngine.dartExecutor.binaryMessenger,
            CHANNEL
        ).setMethodCallHandler { call, result ->
            // Listen to call from Flutter side
            if (call.method.equals("StartBanubaVideoEditor")) {
                exportVideoChanelResult = result
                startVideoEditorModeNormal()
            } else if (call.method.equals("StartBanubaVideoEditorPIP")) {
                exportVideoChanelResult = result

                val videoFilePath = call.arguments as? String
                Log.d(TAG, "Trying to start video editor in pip mode with video = $videoFilePath")

                val videoUri = videoFilePath?.let { Uri.fromFile(File(it)) }
                if (videoUri == null) {
                    Log.w(
                        TAG,
                        "Cannot create 'Uri' to start video editor in PIP mode with video = $videoFilePath."
                    )
                } else {
                    startVideoEditorModePIP(videoUri)
                }
            } else {
                result.notImplemented()
            }
        }
    }

    // Observe export video results
    override fun onActivityResult(requestCode: Int, result: Int, intent: Intent?) {
        if (requestCode == VIDEO_EDITOR_REQUEST_CODE) {
            val exportedVideoResult = if (result == Activity.RESULT_OK) {
                intent?.getParcelableExtra(EXTRA_EXPORTED_SUCCESS) as? ExportResult.Success
            } else {
                ExportResult.Inactive
            }
            exportVideoChanelResult.success(exportedVideoResult.toString())
        } else {
            // TODO
            //exportVideoChanelResult.success(null)
            super.onActivityResult(requestCode, result, intent)
        }
    }

    private fun startVideoEditorModeNormal() {
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
    }

    private fun startVideoEditorModePIP(pipVideo: Uri) {
        startActivityForResult(
            VideoCreationActivity.startFromCamera(
                context = this,
                // setup data that will be acceptable during export flow
                additionalExportData = null,
                // set TrackData object if you open VideoCreationActivity with preselected music track
                audioTrackData = null,
                // set PiP video configuration
                pictureInPictureConfig = PipConfig(
                    video = pipVideo,
                    openPipSettings = false
                )
            ), VIDEO_EDITOR_REQUEST_CODE
        )
    }

}
