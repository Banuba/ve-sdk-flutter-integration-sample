package com.banuba.flutter.flutter_ve_sdk

import io.flutter.app.FlutterApplication

class SampleApp : FlutterApplication() {

    override fun onCreate() {
        super.onCreate()
        // Initialize Banuba VE UI SDK
        BanubaVideoEditorUISDK().initialize(this@SampleApp)
    }
}