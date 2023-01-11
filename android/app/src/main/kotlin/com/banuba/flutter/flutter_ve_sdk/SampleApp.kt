package com.banuba.flutter.flutter_ve_sdk

import io.flutter.app.FlutterApplication
import android.util.Log
import com.banuba.sdk.token.storage.license.BanubaVideoEditor
import com.banuba.sdk.token.storage.license.LicenseStateCallback

class SampleApp : FlutterApplication() {

    companion object {
        /**
         * true - uses custom audio browser implementation in this sample
         * false - to keep default implementation
         */
        const val USE_CUSTOM_AUDIO_BROWSER = false

        const val TAG = "FlutterVideoEditor"

        // Please set your license token for Banuba Video Editor SDK
        private const val LICENSE_TOKEN = SET YOUR LICENSE TOKEN HERE

        const val ERR_SDK_NOT_INITIALIZED = "Banuba Video Editor SDK is not initialized: license token is unknown or incorrect.\nPlease check your license token or contact Banuba"
        const val ERR_LICENSE_REVOKED = "License is revoked or expired. Please contact Banuba https://www.banuba.com/faq/kb-tickets/new"
    }

    var videoEditor: BanubaVideoEditor? = null

    override fun onCreate() {
        super.onCreate()

        videoEditor = BanubaVideoEditor.initialize(LICENSE_TOKEN)

        if (videoEditor == null) {
            // Token you provided is not correct - empty or truncated
            Log.e(TAG, ERR_SDK_NOT_INITIALIZED)
        } else {
            // Initialize Banuba VE UI SDK
            BanubaVideoEditorSDK().initialize(this@SampleApp)
        }
    }
}