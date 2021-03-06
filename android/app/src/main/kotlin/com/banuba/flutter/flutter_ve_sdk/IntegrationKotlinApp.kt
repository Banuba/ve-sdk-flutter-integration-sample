package com.banuba.flutter.flutter_ve_sdk

import com.banuba.flutter.flutter_ve_sdk.videoeditor.di.VideoEditorKoinModule
import com.banuba.sdk.arcloud.di.ArCloudKoinModule
import com.banuba.sdk.effectplayer.adapter.BanubaEffectPlayerKoinModule
import com.banuba.sdk.token.storage.di.TokenStorageKoinModule
import com.banuba.sdk.gallery.di.GalleryKoinModule
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
                    ArCloudKoinModule().module,
                    TokenStorageKoinModule().module,
                    VideoEditorKoinModule().module,
                    BanubaEffectPlayerKoinModule().module,
                    GalleryKoinModule().module
            )
        }
    }
}