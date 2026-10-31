package com.who.zone

import android.content.Context
import android.view.Surface
import com.elvishew.xlog.XLog
import java.io.File
import kotlin.concurrent.thread

object WhoZoneRep {
    const val READER_WIDTH = 640
    const val READER_HEIGHT = 480
    const val MODEL_WIDTH = 320
    const val MODEL_HEIGHT = 320

    private var engineThread: Thread? = null

    // Runs in the background, nothing here should delay the first frame of the app
    fun initEngine(context: Context) {
        engineThread = thread(name = "EngineInit") { loadEngine(context) }
    }

    fun awaitEngine() {
        engineThread?.join()
    }

    private fun loadEngine(context: Context) {
        try {
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
            this.imageReaderWidth = READER_WIDTH
            this.imageReaderHeight = READER_HEIGHT
            this.modelFrameWidth = MODEL_WIDTH
            this.modelFrameHeight = MODEL_HEIGHT
        }.build().toByteArray()
        init(propertyArray, propertyArray.size)
    }

    private fun loadClassNames(context: Context): List<String> {
        return context.assets.open("coco.names").bufferedReader().readLines()
            .filter { it.isNotBlank() }
    }

    fun copyModelToCache(context: Context): String {
        File(context.cacheDir, "yolo11n.onnx").delete()
        copyAssetToCache(context, "yolo11n.ncnn.bin")
        return copyAssetToCache(context, "yolo11n.ncnn.param").absolutePath
    }

    private fun copyAssetToCache(context: Context, name: String): File {
        val file = File(context.cacheDir, name)
        if (!file.exists()) {
            // via a temp file, so a killed process can't leave half of the model behind
            val temp = File(context.cacheDir, "$name.tmp")
            context.assets.open(name).use { input ->
                temp.outputStream().use { output ->
                    input.copyTo(output)
                }
            }
            temp.renameTo(file)
        }
        return file
    }

    private external fun init(data: ByteArray, len: Int)
    external fun nativeInitImageReader(): Surface
    external fun setCameraMeta(data: ByteArray, len: Int)
    external fun nativeSaveOneFrame(path: String)
}