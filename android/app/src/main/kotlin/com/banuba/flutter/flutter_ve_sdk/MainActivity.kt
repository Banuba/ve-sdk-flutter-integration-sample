package com.banuba.flutter.flutter_ve_sdk

import android.content.Intent
import android.net.Uri
import android.os.Bundle
import android.util.Log
import androidx.core.content.FileProvider
import com.banuba.sdk.cameraui.data.PipConfig
import com.banuba.sdk.core.license.BanubaVideoEditor
import com.banuba.sdk.core.license.LicenseStateCallback
import com.banuba.sdk.export.data.ExportResult
import com.banuba.sdk.export.utils.EXTRA_EXPORTED_SUCCESS
import com.banuba.sdk.pe.PhotoCreationActivity
import com.banuba.sdk.ve.flow.VideoCreationActivity
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant
import java.io.File

class MainActivity : FlutterActivity() {

    companion object {
        const val TAG = "FlutterVideoEditor"

        /**
         * true - uses custom audio browser implementation in this sample
         * false - to keep default implementation
         */
        const val CONFIG_ENABLE_CUSTOM_AUDIO_BROWSER = false

        // For Video Editor
        private const val VIDEO_EDITOR_REQUEST_CODE = 7788
        private const val METHOD_INIT_VIDEO_EDITOR = "initVideoEditor"
        private const val METHOD_START_VIDEO_EDITOR = "startVideoEditor"
        private const val METHOD_START_VIDEO_EDITOR_PIP = "startVideoEditorPIP"
        private const val METHOD_START_VIDEO_EDITOR_TRIMMER = "startVideoEditorTrimmer"
        private const val METHOD_DEMO_PLAY_EXPORTED_VIDEO = "playExportedVideo"

        private const val ARG_EXPORTED_VIDEO_FILE = "argExportedVideoFilePath"
        private const val ARG_EXPORTED_VIDEO_COVER = "argExportedVideoCoverPreviewPath"

        // For Photo Editor
        private const val PHOTO_EDITOR_REQUEST_CODE = 8888
        private const val METHOD_START_PHOTO_EDITOR = "startPhotoEditor"

        private const val ARG_EXPORTED_PHOTO_FILE = "argExportedPhotoFilePath"

        // Errors code
        private const val ERR_CODE_SDK_NOT_INITIALIZED = "ERR_SDK_NOT_INITIALIZED"
        private const val ERR_CODE_SDK_LICENSE_REVOKED = "ERR_SDK_LICENSE_REVOKED"
    }

    private var exportResult: MethodChannel.Result? = null

    private var editorSDK: BanubaVideoEditor? = null
    private var videoEditorModule: VideoEditorModule? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        val appFlutterEngine = requireNotNull(flutterEngine)
        GeneratedPluginRegistrant.registerWith(appFlutterEngine)

        MethodChannel(
            appFlutterEngine.dartExecutor.binaryMessenger,
            "banubaSdkChannel"
        ).setMethodCallHandler { call, result ->
            // Initialize export result callback to deliver the results back to Flutter
            exportResult = result

            when (call.method) {
                METHOD_INIT_VIDEO_EDITOR -> {
                    val licenseToken = call.arguments as String
                    editorSDK = BanubaVideoEditor.initialize(licenseToken)

                    if (editorSDK == null) {
                        // The SDK token is incorrect - empty or truncated
                        result.error(ERR_CODE_SDK_NOT_INITIALIZED, "", null)
                    } else {
                        if (videoEditorModule == null) {
                            // Initialize video editor sdk dependencies
                            videoEditorModule = VideoEditorModule().apply {
                                initialize(application)
                            }
                        }
                        result.success(null)
                    }
                }

                METHOD_START_VIDEO_EDITOR -> {
                    checkSdkLicense(
                        callback = { isValid ->
                            if (isValid) {
                                // ✅ The license is active
                                startVideoEditorModeNormal()
                            } else {
                                // ❌ Use of SDK is restricted: the license is revoked or expired
                                result.error(ERR_CODE_SDK_LICENSE_REVOKED, "", null)
                            }
                        },
                        onError = { result.error(ERR_CODE_SDK_NOT_INITIALIZED, "", null) }
                    )
                }

                METHOD_START_VIDEO_EDITOR_PIP -> {
                    val videoFilePath = call.arguments as? String
                    val pipVideoUri = videoFilePath?.let { Uri.fromFile(File(it)) }
                    if (pipVideoUri == null) {
                        Log.w(
                            TAG,
                            "Cannot start video editor in PIP mode: missing or invalid passed video = $videoFilePath"
                        )
                        exportResult?.error(
                            "ERR_START_PIP_MISSING_VIDEO",
                            "Missing video to start video editor in PIP mode",
                            null
                        )
                    } else {
                        checkSdkLicense(
                            callback = { isValid ->
                                if (isValid) {
                                    // ✅ The license is active
                                    startVideoEditorModePIP(pipVideoUri)
                                } else {
                                    // ❌ Use of SDK is restricted: the license is revoked or expired
                                    result.error(ERR_CODE_SDK_LICENSE_REVOKED, "", null)
                                }
                            },
                            onError = { result.error(ERR_CODE_SDK_NOT_INITIALIZED, "", null) }
                        )
                    }
                }

                METHOD_START_VIDEO_EDITOR_TRIMMER -> {
                    val videoFilePath = call.arguments as? String
                    val trimmerVideoUri = videoFilePath?.let { Uri.fromFile(File(it)) }
                    if (trimmerVideoUri == null) {
                        Log.w(
                            TAG,
                            "Cannot start video editor in Trimmer mode: missing or invalid passed video = $videoFilePath"
                        )
                        exportResult?.error("ERR_START_TRIMMER_MISSING_VIDEO", "", null)
                    } else {
                        checkSdkLicense(
                            callback = { isValid ->
                                if (isValid) {
                                    // ✅ The license is active
                                    startVideoEditorModeTrimmer(trimmerVideoUri)
                                } else {
                                    // ❌ Use of SDK is restricted: the license is revoked or expired
                                    result.error(ERR_CODE_SDK_LICENSE_REVOKED, "", null)
                                }
                            },
                            onError = { result.error(ERR_CODE_SDK_NOT_INITIALIZED, "", null) }
                        )
                    }
                }

                METHOD_START_PHOTO_EDITOR -> {
                    val licenseToken = call.arguments as String
                    editorSDK = BanubaVideoEditor.initialize(licenseToken)

                    if (editorSDK == null) {
                        // The SDK token is incorrect - empty or truncated
                        result.error(ERR_CODE_SDK_NOT_INITIALIZED, "", null)
                    } else {
                        checkSdkLicense(
                            callback = { isValid ->
                                if (isValid) {
                                    // ✅ The license is active
                                    startActivityForResult(
                                        PhotoCreationActivity.startFromGallery(this),
                                        PHOTO_EDITOR_REQUEST_CODE
                                    )
                                } else {
                                    // ❌ Use of SDK is restricted: the license is revoked or expired
                                    result.error(ERR_CODE_SDK_LICENSE_REVOKED, "", null)
                                }
                            },
                            onError = { result.error(ERR_CODE_SDK_NOT_INITIALIZED, "", null) }
                        )
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
                            "Cannot play exported demo video: missing or invalid = $videoFilePath"
                        )
                        exportResult?.error("ERR_EXPORT_PLAY_MISSING_VIDEO", "", null)
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
        if (requestCode == VIDEO_EDITOR_REQUEST_CODE && result == RESULT_OK) {
            val exportResult =
                intent?.getParcelableExtra(EXTRA_EXPORTED_SUCCESS) as? ExportResult.Success
            if (exportResult == null) {
                this.exportResult?.error(
                    "ERR_MISSING_EXPORT_RESULT",
                    "",
                    null
                )
            } else {
                val data = prepareVideoExportData(exportResult)
                this.exportResult?.success(data)
            }

        } else if (requestCode == PHOTO_EDITOR_REQUEST_CODE && result == RESULT_OK) {
            val data = preparePhotoExportData(intent)
            exportResult?.success(data)
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
    private fun prepareVideoExportData(result: ExportResult.Success): Map<String, Any?> {
        // First exported video file path is used to play video in this sample to demonstrate
        // the result of video export.
        // You can provide your custom logic.
        val firstVideoFilePath = result.videoList[0].sourceUri.toString()
        val videoCoverImagePath = result.preview.toString()
        val data = mapOf(
            ARG_EXPORTED_VIDEO_FILE to firstVideoFilePath,
            ARG_EXPORTED_VIDEO_COVER to videoCoverImagePath
        )
        return data
    }

    // Customize photo export data results to meet your requirements.
    // You can use Map or JSON to pass custom data for your app.
    private fun preparePhotoExportData(result: Intent?): Map<String, Any?> {
        val photoUri = result?.getParcelableExtra(PhotoCreationActivity.EXTRA_EXPORTED) as? Uri
        Log.w(TAG, "preparePhotoExportData = $photoUri")
        val data = mapOf(
            ARG_EXPORTED_PHOTO_FILE to photoUri?.toString()
        )
        return data
    }

    private fun checkSdkLicense(
        callback: LicenseStateCallback,
        onError: () -> Unit
    ) {
        val sdk = editorSDK
        if (sdk == null) {
            Log.e(TAG, "Cannot check license state: initialize the SDK")
            onError()
        } else {
            // Checking the license might take around 1 sec in the worst case.
            // Please optimize use if this method in your application for the best user experience
            sdk.getLicenseState(callback)
        }
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
