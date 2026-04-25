package com.who.zone

import android.Manifest
import android.content.Context
import android.graphics.SurfaceTexture
import android.hardware.camera2.CameraCaptureSession
import android.hardware.camera2.CameraCharacteristics
import android.hardware.camera2.CameraDevice
import android.hardware.camera2.CameraManager
import android.hardware.camera2.CaptureRequest
import android.os.Handler
import android.os.HandlerThread
import android.util.Range
import android.util.Size
import android.view.Surface
import androidx.annotation.RequiresPermission
import app.App
import com.elvishew.xlog.XLog
import kotlin.math.abs

class CameraSession(val context: Context) {
    private var cameraDevice: CameraDevice? = null
    private var session: CameraCaptureSession? = null
    private var bgThread: HandlerThread = HandlerThread("CameraBackground")
    private var bgHandler: Handler
    init {
        bgThread.start()
        bgHandler = Handler(bgThread.looper)
    }

    fun dispose() {
        bgThread.quitSafely()
    }

//    private val cameraId: String,
//    private val fpsRange: Range<Int>,
//    private val previewTexture: TextureProvider?,
//    private val codecSurface: Surface

    @RequiresPermission(Manifest.permission.CAMERA)
    fun startCamera(cameraId: String, codecSurface: Surface) {
        val manager = context.getSystemService(Context.CAMERA_SERVICE) as CameraManager
        manager.openCamera(cameraId, object : CameraDevice.StateCallback() {
            override fun onOpened(camera: CameraDevice) {
                XLog.tag(TAG).i( "onOpened: id=${camera.id}")
                cameraDevice = camera
                startSession(camera, codecSurface)
            }
            override fun onDisconnected(camera: CameraDevice) {
                XLog.tag(TAG).i( "onDisconnected: id=${cameraDevice?.id}")
                cameraDevice?.close()
                cameraDevice = null
            }
            override fun onError(camera: CameraDevice, error: Int) {
                val errorMessage = when (error) {
                    ERROR_CAMERA_DEVICE -> "Fatal camera device error."
                    ERROR_CAMERA_DISABLED -> "Camera is disabled."
                    ERROR_CAMERA_IN_USE -> "Camera is already in use."
                    ERROR_MAX_CAMERAS_IN_USE -> "Maximum cameras in use."
                    ERROR_CAMERA_SERVICE -> "Fatal camera service"
                    else -> "Unknown camera error: $error"
                }
                XLog.tag(TAG).i( "onError: id=${camera.id}, error=$errorMessage")
            }
        }, bgHandler)
    }

    fun stopCamera() {
        try {
            session?.stopRepeating()
            session?.abortCaptures()
        } catch (e: Exception) {
            XLog.tag(TAG).i( "ex", e)
        }
        try {
            cameraDevice?.close()
            cameraDevice = null
        } catch (e: Exception) {
            XLog.tag(TAG).i( "ex", e)
        }
    }

    private fun startSession(device: CameraDevice, codecSurface: Surface) {
        try {
            val info = getCameraInfo(device.id) ?: return
            val range = info.fpsRangesList.first()
            val builder = device.createCaptureRequest(CameraDevice.TEMPLATE_RECORD)
            builder.addTarget(codecSurface)
            builder.set(
                CaptureRequest.CONTROL_AE_TARGET_FPS_RANGE,
                Range(range.lower, range.upper)
            )
            device.createCaptureSession(listOf(codecSurface),object : CameraCaptureSession.StateCallback() {
                    override fun onConfigured(session: CameraCaptureSession) {
                        this@CameraSession.session = session
                        try {
                            session.setRepeatingRequest(
                                builder.build(),
                                null,
                                bgHandler
                            )
                        } catch (e: Exception) {
                            XLog.tag(TAG).i( "exception: ${e.message}")
                        }
                    }
                    override fun onConfigureFailed(session: CameraCaptureSession) {
                        XLog.tag(TAG).i( "failed: ${session.device}")
                    }
                }, bgHandler
            )
        } catch (e: Exception) {
            XLog.tag(TAG).i( "exception: ${e.message}")
        }
    }

    fun findBestResolution(cameraSizes: Array<Size>?, encodeWidth: Int, encodeHeight: Int): Size? {
        var resultSize: Size ?= null
        if(cameraSizes == null) return null
        var w = 0
        var h = 0
        for (size in cameraSizes) {
            if(((size.width == encodeWidth) && (size.height == encodeHeight))||
                ((size.width == encodeHeight) && (size.height == encodeWidth))) {
                w = size.width
                h = size.height
                resultSize = size
                break
            } else {
                // TODO: this is wrong
                if (((abs(size.width - encodeWidth) < abs(w - encodeWidth)) &&
                            (abs(size.height - encodeHeight) < abs(h - encodeHeight)))
                    || (w == 0)) {
                    resultSize = size
                }
            }
        }
        return resultSize
    }

    fun findBestFps(fpsRanges: Array<Range<Int>>, targetFps: Int): Range<Int>? {
        if(fpsRanges.isEmpty()) {
            return null
        }
        // TODO: test this
        for (i in fpsRanges.indices) {
            val range = fpsRanges[i]
            if (range.lower <= targetFps && range.upper >= targetFps) {
                return range
            }
        }
        val fpsId = fpsRanges.size - 1
        return if(fpsRanges[fpsId].upper > targetFps) {
            fpsRanges[fpsId]
        } else {
            fpsRanges[fpsId]
        }
    }

    fun getCameras() : List<App.CameraInfo> {
        val result = mutableListOf<App.CameraInfo>()
        try {
            val cameraManager = context.getSystemService(Context.CAMERA_SERVICE) as CameraManager
            val cameraIds = cameraManager.cameraIdList
            for (id in cameraIds) {
                val info = getCameraInfo(id)
                if (info != null) {
                    result.add(info)
                }
            }
        } catch (e: Exception) {
            XLog.tag(TAG).e( "get cameras ex", e)
        }
        return result
    }

    fun getCameraInfo(id: String) : App.CameraInfo? {
        try {
            val characteristics: CameraCharacteristics
            try {
                val cameraManager = context.getSystemService(Context.CAMERA_SERVICE) as CameraManager
                characteristics = cameraManager.getCameraCharacteristics(id)
            } catch (e: Exception) {
                XLog.tag(TAG).i( "exception get characteristics: ${e.message}")
                return null
            }
            val sensorRotation = characteristics.get(CameraCharacteristics.SENSOR_ORIENTATION) ?: 0
            val streamConfMap = characteristics.get(CameraCharacteristics.SCALER_STREAM_CONFIGURATION_MAP)!!
            val fpsRanges = characteristics.get(CameraCharacteristics.CONTROL_AE_AVAILABLE_TARGET_FPS_RANGES)
            val isFront = when (characteristics.get(CameraCharacteristics.LENS_FACING)) {
                CameraCharacteristics.LENS_FACING_FRONT -> true
                CameraCharacteristics.LENS_FACING_BACK -> false
                else -> false
            }
            if(fpsRanges == null) {
                XLog.tag(TAG).i( "ranges null")
                return null
            }
            val cameraSizes = streamConfMap.getOutputSizes(SurfaceTexture::class.java)
            val info = App.CameraInfo.newBuilder().apply {
                this.id = id
                this.sensorRotation = sensorRotation
                this.isFront = isFront
                for(size in cameraSizes) {
                    this.cameraSizesList.add(App.Size.newBuilder().apply {
                        this.width = size.width
                        this.height = size.height
                    }.build())
                }
                for(range in fpsRanges) {
                    this.fpsRangesList.add(
                        App.Range.newBuilder().apply {
                            this.lower = range.lower
                            this.upper = range.upper
                        }.build()
                    )
                }
            }
            return info.build()
        } catch (e: Exception) {
            XLog.tag(TAG).e( "ex: ${e.message}")
        }
        return null
    }

    companion object {
        private const val TAG = "CameraSession"
    }
}