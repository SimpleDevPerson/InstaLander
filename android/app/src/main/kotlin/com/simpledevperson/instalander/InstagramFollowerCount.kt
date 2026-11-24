package com.simpledevperson.instalander

import android.net.Network
import android.os.SystemClock
import android.text.Html
import java.io.IOException
import java.net.HttpURLConnection
import java.net.URI
import java.net.URL

internal object InstagramFollowerCount {
    private val username = Regex("[a-zA-Z0-9_.]{1,30}")
    private val headEnd = Regex("</head\\s*>", RegexOption.IGNORE_CASE)
    private val tags = Regex(
        """<!--.*?-->|<(script|style|title)\b[^>]*>.*?</\1\s*>|<(meta|link)\b((?:"[^"]*"|'[^']*'|[^'">]++)*+)>""",
        setOf(RegexOption.IGNORE_CASE, RegexOption.DOT_MATCHES_ALL),
    )
    private val attribute = Regex("""([^\s"'<>/=]+)\s*=\s*(?:"([^"]*)"|'([^']*)'|([^\s"'=<>`]+))""")
    private val description = Regex(
        """^\s*(?:(\d+)(?:[.,](\d+))?\s*([KMB])|(\d{1,3}(?:[,\x{A0}\x{202F} ]\d{3})+|\d+))\s+Followers?\b""",
        RegexOption.IGNORE_CASE,
    )
    private const val HEAD_LIMIT = 256 * 1024

    fun normalize(input: String): String? {
        val name = input.trim().removePrefix("@").lowercase()
        return name.takeIf { username.matches(it) && it != "." && it != ".." && !it.startsWith("debug_") }
    }

    data class Result(val count: Long? = null, val throttled: Boolean = false)

    class Request {
        @Volatile private var cancelled = false
        @Volatile private var connection: HttpURLConnection? = null

        fun cancel() {
            cancelled = true
            val active = connection ?: return
            // Disconnect off the main thread since the network stream may be closing.
            Thread({ active.disconnect() }, "Instagram count disconnect").start()
        }

        fun fetch(name: String, network: Network? = null): Result {
            if (cancelled || normalize(name) != name) return Result()
            val deadline = SystemClock.elapsedRealtime() + 6_000
            val url = URL("https://www.instagram.com/$name/")
            return try {
                val request = (network?.openConnection(url) ?: url.openConnection()) as HttpURLConnection
                connection = request
                if (cancelled) return Result()
                request.instanceFollowRedirects = false
                request.connectTimeout = 4_000
                request.readTimeout = 2_000
                request.setRequestProperty("Accept-Language", "en-US,en;q=0.9")
                when (request.responseCode) {
                    429 -> Result(throttled = true)
                    200 -> {
                        val head = StringBuilder()
                        val buffer = CharArray(4_096)
                        request.inputStream.bufferedReader(Charsets.UTF_8).use { reader ->
                            while (!cancelled && SystemClock.elapsedRealtime() < deadline) {
                                val length = reader.read(buffer)
                                if (length < 0) break
                                val previousLength = head.length
                                head.append(buffer, 0, length)
                                val end = headEnd.find(head, (previousLength - 16).coerceAtLeast(0))
                                if (end != null && end.range.last < HEAD_LIMIT) {
                                    head.setLength(end.range.first)
                                    break
                                }
                                if (head.length > HEAD_LIMIT) return Result()
                            }
                        }
                        if (cancelled || SystemClock.elapsedRealtime() >= deadline) Result()
                        else Result(parse(head, name))
                    }
                    else -> Result()
                }
            } catch (_: IOException) {
                Result()
            } catch (_: SecurityException) {
                Result()
            } finally {
                connection?.disconnect()
                connection = null
            }
        }
    }

    internal fun parse(head: CharSequence, name: String): Long? {
        var canonical: String? = null
        var openGraphUrl: String? = null
        var followerDescription: String? = null
        for (tag in tags.findAll(head)) {
            val type = tag.groups[2]?.value?.lowercase() ?: continue
            val fields = mutableMapOf<String, String>()
            for (field in attribute.findAll(tag.groupValues[3])) {
                val value = (2..4).firstNotNullOf { field.groups[it]?.value }
                fields.putIfAbsent(field.groupValues[1].lowercase(), value)
            }
            when {
                type == "link" && fields["rel"] == "canonical" && canonical == null ->
                    canonical = fields["href"]
                type == "meta" && fields["property"] == "og:url" && openGraphUrl == null ->
                    openGraphUrl = fields["content"]
                type == "meta" && fields["property"] == "og:description" && followerDescription == null ->
                    followerDescription = fields["content"]
            }
        }
        val url = (openGraphUrl ?: canonical)?.let { runCatching { URI(decode(it)) }.getOrNull() }
        val host = url?.host?.lowercase()
        val path = url?.path?.lowercase()
        if (url?.scheme != "https" || host !in listOf("www.instagram.com", "instagram.com") ||
            (url.port != -1 && url.port != 443) || url.userInfo != null ||
            (path != "/$name/" && path != "/$name")) return null

        val match = description.find(decode(followerDescription ?: return null)) ?: return null
        match.groups[4]?.let { return it.value.filter(Char::isDigit).toLongOrNull() }
        val scale = when (match.groupValues[3].uppercase()) {
            "K" -> 3
            "M" -> 6
            else -> 9
        }
        val fraction = match.groupValues[2].padEnd(scale, '0').take(scale)
        return (match.groupValues[1] + fraction).toLongOrNull()
    }

    private fun decode(value: String): String =
        if ('&' in value) Html.fromHtml(value, Html.FROM_HTML_MODE_LEGACY).toString() else value
}
