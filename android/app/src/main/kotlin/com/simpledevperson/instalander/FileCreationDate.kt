package com.simpledevperson.instalander

import android.content.Context
import android.net.Uri
import android.os.Build
import android.os.ParcelFileDescriptor
import java.io.File

object FileCreationDate {
    private val available = try {
        System.loadLibrary("file_metadata")
        true
    } catch (_: UnsatisfiedLinkError) {
        false
    }

    private external fun readBirthTime(fd: Int): Long

    fun read(context: Context, source: String): Long? {
        // Older Android versions may block statx in their syscall sandbox.
        if (Build.VERSION.SDK_INT < 30 || !available) return null
        return try {
            val uri = Uri.parse(source)
            val descriptor = when (uri.scheme) {
                "content" -> context.contentResolver.openFileDescriptor(uri, "r")
                "file" -> ParcelFileDescriptor.open(File(uri.path!!), ParcelFileDescriptor.MODE_READ_ONLY)
                else -> null
            }
            descriptor?.use { readBirthTime(it.fd).takeIf { time -> time > 0 } }
        } catch (_: Exception) {
            // Cloud providers, pipes and older kernels may not expose birth time.
            null
        }
    }
}
