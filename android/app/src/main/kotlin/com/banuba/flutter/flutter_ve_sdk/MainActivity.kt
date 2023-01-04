package com.banuba.flutter.flutter_ve_sdk

import android.app.Activity
import android.content.Intent
import android.net.Uri
import android.os.Bundle
import android.util.Log
import androidx.core.content.FileProvider
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

        private const val METHOD_START_VIDEO_EDITOR = "StartBanubaVideoEditor"
        private const val METHOD_START_VIDEO_EDITOR_PIP = "StartBanubaVideoEditorPIP"
        private const val METHOD_START_VIDEO_EDITOR_TRIMMER = "StartBanubaVideoEditorTrimmer"
        private const val METHOD_DEMO_PLAY_EXPORTED_VIDEO = "PlayExportedVideo"

        private const val ERR_MISSING_EXPORT_RESULT = "ERR_MISSING_EXPORT_RESULT"
        private const val ERR_START_PIP_MISSING_VIDEO = "ERR_START_PIP_MISSING_VIDEO"
        private const val ERR_START_TRIMMER_MISSING_VIDEO = "ERR_START_TRIMMER_MISSING_VIDEO"
        private const val ERR_EXPORT_PLAY_MISSING_VIDEO = "ERR_EXPORT_PLAY_MISSING_VIDEO"

        private const val ARG_EXPORTED_VIDEO_FILE = "exportedVideoFilePath"

        private const val CHANNEL = "startActivity/VideoEditorChannel"
    }

    private var exportVideoChanelResult: MethodChannel.Result? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        val appFlutterEngine = requireNotNull(flutterEngine)
        GeneratedPluginRegistrant.registerWith(appFlutterEngine)

        MethodChannel(
            appFlutterEngine.dartExecutor.binaryMessenger,
            CHANNEL
        ).setMethodCallHandler { call, result ->
            // Initialize export result callback that will allow to deliver results back to Flutter
            exportVideoChanelResult = result

            when (call.method) {
                METHOD_START_VIDEO_EDITOR -> startVideoEditorModeNormal()

                METHOD_START_VIDEO_EDITOR_PIP -> {
                    val videoFilePath = call.arguments as? String
                    val pipVideoUri = videoFilePath?.let { Uri.fromFile(File(it)) }
                    if (pipVideoUri == null) {
                        Log.w(
                            TAG,
                            "Missing or invalid video file path = [$videoFilePath] to start video editor in PIP mode."
                        )
                        exportVideoChanelResult?.error(
                            ERR_START_PIP_MISSING_VIDEO,
                            "Missing video to start video editor in PIP mode",
                            null
                        )
                    } else {
                        startVideoEditorModePIP(pipVideoUri)
                    }
                }

                METHOD_START_VIDEO_EDITOR_TRIMMER -> {
                    val videoFilePath = call.arguments as? String
                    val trimmerVideoUri = videoFilePath?.let { Uri.fromFile(File(it)) }
                    if (trimmerVideoUri == null) {
                        Log.w(
                                TAG,
                                "Missing or invalid video file path = [$videoFilePath] to start video editor from trimmer."
                        )
                        exportVideoChanelResult?.error(
                                ERR_START_TRIMMER_MISSING_VIDEO,
                                "Missing video to start video editor in trimmer mode",
                                null
                        )
                    } else {
                        startVideoEditorModeTrimmer(trimmerVideoUri)
                    }
                }

                /*
                NOT REQUIRED FOR INTEGRATION
                Added for playing exported video file.
                */
                METHOD_DEMO_PLAY_EXPORTED_VIDEO -> {
                    val videoFilePath = call.arguments as? String
                    val exportedVideoUri = videoFilePath?.let { Uri.fromFile(File(it)) }

                    if (exportedVideoUri == null) {
                        Log.w(
                            TAG,
                            "Missing or invalid video file path = [$videoFilePath] to play video."
                        )
                        exportVideoChanelResult?.error(
                            ERR_EXPORT_PLAY_MISSING_VIDEO,
                            "Missing exported video file path to play",
                            null
                        )
                    } else {
                        demoPlayExportedVideo(exportedVideoUri)
                        result.success(null)
                    }
                }

                else -> result.notImplemented()
            }
        }
    }

    // Observe export video results
    override fun onActivityResult(requestCode: Int, result: Int, intent: Intent?) {
        super.onActivityResult(requestCode, result, intent)

        if (requestCode == VIDEO_EDITOR_REQUEST_CODE) {
            if (result == Activity.RESULT_OK) {
                val exportResult =
                    intent?.getParcelableExtra(EXTRA_EXPORTED_SUCCESS) as? ExportResult.Success
                if (exportResult == null) {
                   exportVideoChanelResult?.error(
                        ERR_MISSING_EXPORT_RESULT,
                        "Export finished with no result!",
                        null
                    )
                } else {
                    val data = prepareExportData(exportResult)
                    exportVideoChanelResult?.success(data)
                }
            }
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

    private fun startVideoEditorModeTrimmer(trimmerVideo: Uri) {
        startActivityForResult(
                VideoCreationActivity.startFromTrimmer(
                        context = this,
                        // setup data that will be acceptable during export flow
                        additionalExportData = null,
                        // set TrackData object if you open VideoCreationActivity with preselected music track
                        audioTrackData = null,
                        // set Trimmer video configuration
                        predefinedVideos = arrayOf(trimmerVideo)
                ), VIDEO_EDITOR_REQUEST_CODE
        )
    }

    // Customize export data results to meet your requirements.
    // You can use Map or JSON to pass custom data for your app.
    private fun prepareExportData(result: ExportResult.Success): Map<String, Any?> {
        // First exported video file path is used to play video in this sample to demonstrate
        // the result of video export.
        // You can provide your custom logic.
        val firstVideoFilePath = result.videoList[0].sourceUri.toString()
        val data = mapOf(
            ARG_EXPORTED_VIDEO_FILE to firstVideoFilePath
        )
        return data
    }

    /*
    NOT REQUIRED FOR INTEGRATION
    Added for playing exported video file.
    */
    private fun demoPlayExportedVideo(videoUri: Uri) {
        val intent = Intent(Intent.ACTION_VIEW).apply {
            addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
            val uri = FileProvider.getUriForFile(
                applicationContext,
                "$packageName.provider",
                File(videoUri.encodedPath)
            )
            setDataAndType(uri, "video/mp4")
        }
        startActivity(intent)
    }
}
