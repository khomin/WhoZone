package com.who.zone

import android.media.ImageReader
import android.view.Surface
import com.elvishew.xlog.XLog

object WhoZoneRep {
    fun initEngine() {
        try {
            System.loadLibrary("WhoZone")
        } catch (e: Exception) {
            XLog.e("Failed to open library", e.toString())
        }

        val property = app.App.InitParam.newBuilder()
        val propertyArray = property.build().toByteArray()
        init(propertyArray, propertyArray.size)
    }

    private external fun init(toByteArray: ByteArray, len: Int)
    external fun nativeInitImageReader(reader: ImageReader)
    external fun nativeSetOutputWindow(surface: Surface)
}