package com.banuba.flutter.flutter_ve_sdk

import com.banuba.flutter.flutter_ve_sdk.videoeditor.di.IntegrationKoinModule
import com.banuba.sdk.arcloud.di.ArCloudKoinModule
import com.banuba.sdk.effectplayer.adapter.BanubaEffectPlayerKoinModule
import com.banuba.sdk.export.di.VeExportKoinModule
import com.banuba.sdk.gallery.di.GalleryKoinModule
import com.banuba.sdk.playback.di.VePlaybackSdkKoinModule
import com.banuba.sdk.token.storage.di.TokenStorageKoinModule
import com.banuba.sdk.ve.di.VeSdkKoinModule
import com.banuba.sdk.ve.flow.di.VeFlowKoinModule
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
                VeSdkKoinModule().module,
                VeExportKoinModule().module,
                ArCloudKoinModule().module,
                TokenStorageKoinModule().module,
                VeFlowKoinModule().module,
                IntegrationKoinModule().module,
                BanubaEffectPlayerKoinModule().module,
                GalleryKoinModule().module,
                VePlaybackSdkKoinModule().module
            )
        }
    }
}