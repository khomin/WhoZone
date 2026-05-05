package com.who.zone

import android.os.Build
import android.os.Bundle
import android.view.Surface
import androidx.activity.result.contract.ActivityResultContracts
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.cancel
import kotlin.collections.get

class MainActivity : FlutterFragmentActivity() {
    private val coroutineScope = CoroutineScope(Dispatchers.IO)
    private lateinit var cameraSession: CameraSession
    private var cameraPermissionResult: MethodChannel.Result ?= null

    val permissionLauncher = registerForActivityResult(ActivityResultContracts.RequestPermission()) { isGranted: Boolean ->
        cameraPermissionResult?.success(isGranted)
        cameraPermissionResult = null
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        cameraSession = CameraSession(applicationContext)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        val registry = flutterEngine.renderer
        val channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL_NAME)
        val textureRep = TextureRepository(registry) {}

        channel.setMethodCallHandler { call, result ->
            val args = call.arguments as HashMap<*, *>
            when (call.method) {
                "get_model_target_size" -> {
                    val map = mutableMapOf<String, Int>()
                    map["width"] = WhoZoneRep.READER_WIDTH
                    map["height"] = WhoZoneRep.READER_HEIGHT
                    result.success(map)
                    return@setMethodCallHandler
                }
                "get_cameras" -> {
                    val map = mutableMapOf<String, ByteArray>()
                    val cameras = cameraSession.getCameras()
                    for(i in cameras) {
                        map[i.id] = i.toByteArray()
                    }
                    result.success(map)
                    return@setMethodCallHandler
                }
                "request_camera_permissions" -> {
                    try {
                        cameraPermissionResult = result
                        permissionLauncher.launch(android.Manifest.permission.CAMERA)
                    } catch (e: SecurityException) {
                        result.error(TAG, e.message, e)
                    }
                    return@setMethodCallHandler
                }
                "register_texture" -> {
                    val width = args["width"] as Int
                    val height = args["height"] as Int
                    val texture = textureRep.registerTexture(width, height)
                    val map = mutableMapOf<String, Long>().apply {
                        this["id"] = texture.id
                    }
                    result.success(map)
                    return@setMethodCallHandler
                }
                "unregister_texture" -> {
                    val id = args["id"] as Long
                    textureRep.unregisterTexture(id)
                }
                "start_camera" -> {
                    try {
                        val cameraId = args["camera_id"] as String
                        val textureId = (args["texture_id"] as Number).toLong()
                        val texture = textureRep.getTexture(textureId)
                        var success = false
                        if(texture != null) {
                            success = cameraSession.startCamera(cameraId, texture.producer.surface)
                        }
                        result.success(success)
                    } catch (e: SecurityException) {
                        result.error(TAG, e.message, e)
                    }
                    return@setMethodCallHandler
                }
                "stop_camera" -> {
                    cameraSession.stopCamera()
                    result.success(true)
                    return@setMethodCallHandler
                }
                "get_device_sensor" -> {
                    applicationContext?.display?.rotation?.let {
                        when (it) {
                            Surface.ROTATION_0 -> result.success(0)
                            Surface.ROTATION_90 -> result.success(90)
                            Surface.ROTATION_180 -> result.success(180)
                            Surface.ROTATION_270 -> result.success(270)
                        }
                    }
                    return@setMethodCallHandler
                }
                "save_one_frame" -> {
                    val path = args["path"] as String
                    WhoZoneRep.nativeSaveOneFrame(path)
                    result.success(true)
                    return@setMethodCallHandler
                }
            }
            result.success(true)
        }
    }

    override fun onDestroy() {
        super.onDestroy()
        coroutineScope.cancel()
        cameraSession.dispose()
    }

    companion object {
        const val TAG = "MainActivity"
        const val CHANNEL_NAME = "channel_cmd"
    }
}
