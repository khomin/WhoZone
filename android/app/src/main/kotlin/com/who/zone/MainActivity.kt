package com.who.zone

import android.os.Bundle
import androidx.activity.result.contract.ActivityResultContracts
import com.elvishew.xlog.XLog
import com.google.gson.Gson
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
        cameraPermissionResult?.success(true)
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
        val textures = TextureRepository(registry, {})

        channel.setMethodCallHandler { call, result ->
            val args = call.arguments as HashMap<*, *>
            when (call.method) {
                "get_cameras" -> {
                    val cameras = cameraSession.getCameras()
                    val map = mutableMapOf<String, String>()
                    for(i in cameras) {
                        map[i.id] = Gson().toJson(i)
                    }
                    result.success(map)
                    return@setMethodCallHandler
                }
                "register_texture" -> {
                    val width = args["width"] as Int
                    val height = args["height"] as Int
                    val texture = textures.registerTexture(width, height)
                    val map = mutableMapOf<String, Long>().apply {
                        this["id"] = texture.id
                    }
                    result.success(map)
                    return@setMethodCallHandler
                }
                "unregister_texture" -> {
                    val id = args["id"] as Long
                    textures.unregisterTexture(id)
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
                "start_camera" -> {
                    try {
                        val cameraId = args["camera_id"] as String
                        val textureId = args["texture_id"] as Long
                        val texture = textures.getTexture(textureId)
                        if(texture != null) {
                            cameraSession.startCamera(cameraId, texture.producer.surface)
                        }
                        result.success(texture != null)
                    } catch (e: SecurityException) {
                        result.error(TAG, e.message, e)
                    }
                    return@setMethodCallHandler
                }
                "stop_camera" -> {
                    cameraSession.stopCamera()
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
