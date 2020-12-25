package com.banuba.flutter.flutter_ve_sdk.videoeditor.widget

import android.view.animation.Interpolator
import kotlin.math.abs

internal object ReverseInterpolator : Interpolator {

    override fun getInterpolation(input: Float) = abs(input - 1f)
}