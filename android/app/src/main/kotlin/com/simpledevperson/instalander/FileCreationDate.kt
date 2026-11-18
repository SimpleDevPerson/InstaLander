package com.simpledevperson.instalander

import android.content.Context
import android.net.Uri
import android.os.Build
import android.os.ParcelFileDescriptor
import android.provider.DocumentsContract
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
        val uri = Uri.parse(source)
        // Extraction usually preserves the export's modification date, whereas
        // birth time describes the newly extracted file and is often unavailable.
        val modified = try {
            when (uri.scheme) {
                "content" -> context.contentResolver.query(
                    uri,
                    arrayOf(DocumentsContract.Document.COLUMN_LAST_MODIFIED),
                    null, null, null,
                )?.use { cursor ->
                    val column = cursor.getColumnIndex(DocumentsContract.Document.COLUMN_LAST_MODIFIED)
                    if (cursor.moveToFirst() && column >= 0 && !cursor.isNull(column)) {
                        cursor.getLong(column).takeIf { it > 0 }
                    } else null
                }
                "file" -> uri.path?.let { File(it).lastModified().takeIf { time -> time > 0 } }
                else -> null
            }
        } catch (_: Exception) {
            null
        }
        if (modified != null) return modified

        // Older Android versions may block statx in their syscall sandbox.
        if (Build.VERSION.SDK_INT < 30 || !available) return null
        return try {
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
