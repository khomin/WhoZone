package com.who.zone

import android.content.Context
import android.media.ImageReader
import android.os.Build
import android.view.Surface
import com.elvishew.xlog.XLog
import java.io.File

object WhoZoneRep {
    fun initEngine(context: Context) {
        try {
            System.loadLibrary("opencv_core")
            System.loadLibrary("opencv_imgproc")
            System.loadLibrary("opencv_flann")
            System.loadLibrary("opencv_calib3d")
            System.loadLibrary("opencv_objdetect")
            System.loadLibrary("WhoZone")
        } catch (e: Exception) {
            XLog.e("Failed to open library", e.toString())
        }

        val property = app.App.InitParam.newBuilder()
        val propertyArray = property.apply {
            val names = loadClassNames(context)
            if(names.isNotEmpty()) {
                addAllCocoNames(names)
            }
            val modelPath = copyModelToCache(context)
            if(modelPath.isNotEmpty()) {
                setModelPath(modelPath)
            }
            targetWidth = 640
            targetHeight = 480
        }.build().toByteArray()
        init(propertyArray, propertyArray.size)
    }

    private fun loadClassNames(context: Context): List<String> {
        return context.assets.open("coco.names").bufferedReader().readLines()
            .filter { it.isNotBlank() }
    }

    fun copyModelToCache(context: Context): String {
        val modelName = "yolo11n.onnx"
        val modelFile = File(context.cacheDir, modelName)
        if (!modelFile.exists()) {
            context.assets.open(modelName).use { input ->
                modelFile.outputStream().use { output ->
                    input.copyTo(output)
                }
            }
        }
        return modelFile.absolutePath
    }

    private external fun init(toByteArray: ByteArray, len: Int)
    external fun nativeInitImageReader(): Surface
    external fun nativeSetOutputWindow(surface: Surface)
    external fun setCameraSensorRotation(rotation: Int)
}