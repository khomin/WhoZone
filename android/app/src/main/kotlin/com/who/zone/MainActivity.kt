package com.who.zone

import android.media.RingtoneManager
import android.net.Uri
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
import androidx.core.net.toUri
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext

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
                    coroutineScope.launch(Dispatchers.IO) {
                        try {
                            val cameraId = args["camera_id"] as String
                            val textureId = (args["texture_id"] as Number).toLong()
                            val texture = textureRep.getTexture(textureId)
                            var success = false
                            if (texture != null) {
                                success = cameraSession.startCamera(cameraId, texture.producer.surface)
                            }
                            withContext(Dispatchers.Main) {
                                result.success(success)
                            }
                        } catch (e: SecurityException) {
                            withContext(Dispatchers.Main) {
                                result.error(TAG, e.message, e)
                            }
                        }
                    }
                    return@setMethodCallHandler
                }
                "stop_camera" -> {
                    coroutineScope.launch(Dispatchers.IO) {
                        cameraSession.stopCamera()
                        withContext(Dispatchers.Main) {
                            result.success(true)
                        }
                    }
                    return@setMethodCallHandler
                }
                "get_device_sensor" -> {
                    display?.rotation?.let {
                        when (it) {
                            Surface.ROTATION_0 -> result.success(0)
                            Surface.ROTATION_90 -> result.success(90)
                            Surface.ROTATION_180 -> result.success(180)
                            Surface.ROTATION_270 -> result.success(270)
                        }
                    }
                    return@setMethodCallHandler
                }
                "get_system_sounds" -> {
                    coroutineScope.launch(Dispatchers.IO) {
                        val map = mutableMapOf<String, Any>()
                        val manager = RingtoneManager(this@MainActivity)
                        manager.setType(RingtoneManager.TYPE_NOTIFICATION)
                        val cursor = manager.cursor
                        while (cursor.moveToNext()) {
                            val id = cursor.getString(RingtoneManager.ID_COLUMN_INDEX)
                            val uri = cursor.getString(RingtoneManager.URI_COLUMN_INDEX)
                            val name = cursor.getString(RingtoneManager.TITLE_COLUMN_INDEX)
                            map["$uri/$id"] = mapOf("uri" to "$uri/$id", "name" to name)
                        }
                        withContext(Dispatchers.Main) {
                            result.success(map)
                        }
                    }
                    return@setMethodCallHandler
                }
                "play_system_sound" -> {
                    val toneId = args["id"] as String
                    val tone = RingtoneManager.getRingtone(this, toneId.toUri())
                    tone.play()
                    result.success(true)
                    return@setMethodCallHandler
                }
                "save_one_frame" -> {
                    coroutineScope.launch(Dispatchers.IO) {
                        val path = args["path"] as String
                        WhoZoneRep.nativeSaveOneFrame(path)
                        withContext(Dispatchers.Main) {
                            result.success(true)
                        }
                    }
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
