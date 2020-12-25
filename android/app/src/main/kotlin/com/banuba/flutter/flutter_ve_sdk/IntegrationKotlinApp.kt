package com.banuba.flutter.flutter_ve_sdk

import android.app.Application
import com.banuba.flutter.flutter_ve_sdk.videoeditor.di.VideoEditorKoinModule
import com.banuba.sdk.arcloud.di.ArCloudKoinModule
import io.flutter.app.FlutterApplication
import org.koin.android.ext.koin.androidContext
import org.koin.core.context.startKoin

class IntegrationKotlinApp : FlutterApplication() {

    override fun onCreate() {
        super.onCreate()
        startKoin {
            androidContext(this@IntegrationKotlinApp)

            // pass the customized Koin module that implements required dependencies.
            modules(
                    VideoEditorKoinModule().module,
                    ArCloudKoinModule().module
            )
        }
    }
}