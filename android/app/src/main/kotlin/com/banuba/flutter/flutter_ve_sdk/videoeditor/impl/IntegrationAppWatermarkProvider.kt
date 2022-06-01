package com.banuba.flutter.flutter_ve_sdk.videoeditor.impl
import android.graphics.Bitmap
import com.banuba.sdk.ve.effects.watermark.WatermarkProvider

class IntegrationAppWatermarkProvider : WatermarkProvider {

    /**
     * Provide your own watermark image
     * */
    override fun getWatermarkBitmap(): Bitmap? {
        return null
    }
}