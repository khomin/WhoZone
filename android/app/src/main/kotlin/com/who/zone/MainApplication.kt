package com.who.zone

import android.app.Application
import com.elvishew.xlog.LogConfiguration
import com.elvishew.xlog.XLog
import com.elvishew.xlog.flattener.ClassicFlattener
import com.elvishew.xlog.printer.AndroidPrinter
import com.elvishew.xlog.printer.file.FilePrinter
import com.elvishew.xlog.printer.file.backup.FileSizeBackupStrategy2
import com.elvishew.xlog.printer.file.naming.FileNameGenerator
import java.io.File
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale

class MainApplication : Application() {
    override fun onCreate() {
        super.onCreate()

        val logPath = File(getExternalFilesDir(null), "log").absolutePath
        val filePrinter = FilePrinter.Builder(logPath)
            .fileNameGenerator(MyFileNameGenerator())
            .backupStrategy(FileSizeBackupStrategy2(10 * 1024 * 1024, 3)) // 10MB per file, keep 3
            .flattener(ClassicFlattener())
            .build()
        val config = LogConfiguration.Builder()
            .tag("WhoZone")
            .disableThreadInfo()
            .disableStackTrace()
            .build()
        XLog.init(config, AndroidPrinter(), filePrinter)
        setupCrashHandler()

        try {
            System.loadLibrary("WhoZone")
        } catch (e: Exception) {
            XLog.e("Failed to open library", e.toString())
        }
    }

    private fun setupCrashHandler() {
        val defaultHandler = Thread.getDefaultUncaughtExceptionHandler()
        Thread.setDefaultUncaughtExceptionHandler { thread, throwable ->
            XLog.e("FATAL CRASH on thread: ${thread.name}", throwable)
            defaultHandler?.uncaughtException(thread, throwable)
        }
    }
}

class MyFileNameGenerator : FileNameGenerator {
    override fun isFileNameChangeable(): Boolean = true
    override fun generateFileName(logLevel: Int, timestamp: Long): String {
        val sdf = SimpleDateFormat("yyyy-MM-dd", Locale.getDefault())
        val dateStr = sdf.format(Date(timestamp))
        return "android_$dateStr.log"
    }
}