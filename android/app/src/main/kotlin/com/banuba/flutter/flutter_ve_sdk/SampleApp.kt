package com.banuba.flutter.flutter_ve_sdk

import io.flutter.app.FlutterApplication

class SampleApp : FlutterApplication() {

    companion object {
        /**
         * true - uses custom audio browser implementation in this sample
         * false - to keep default implementation
         */
        const val USE_CUSTOM_AUDIO_BROWSER = false
    }

    override fun onCreate() {
        super.onCreate()
        // Initialize Banuba VE UI SDK
        BanubaVideoEditorSDK().initialize(this@SampleApp)
    }
}