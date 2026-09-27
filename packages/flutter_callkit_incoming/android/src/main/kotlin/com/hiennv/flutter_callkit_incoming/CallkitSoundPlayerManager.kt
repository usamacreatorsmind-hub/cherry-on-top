package com.hiennv.flutter_callkit_incoming

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.media.AudioAttributes
import android.media.AudioManager
import android.media.MediaPlayer
import android.media.RingtoneManager
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.os.VibrationEffect
import android.os.Vibrator
import android.os.VibratorManager
import android.text.TextUtils
import java.util.Timer
import java.util.TimerTask

class CallkitSoundPlayerManager(private val context: Context) {

    private var vibrator: Vibrator? = null
    private var audioManager: AudioManager? = null

    // ✅ FIXED: Use MediaPlayer instead of Ringtone API
    // Ringtone API with STREAM_RING is unreliable on Realme/ColorOS OEMs
    // MediaPlayer with STREAM_MUSIC ALWAYS routes to loudspeaker
    private var mediaPlayer: MediaPlayer? = null

    var isPlaying: Boolean = false
        private set

    private var keepRingingForFullScreenIntent: Boolean = false

    inner class ScreenOffCallkitIncomingBroadcastReceiver : BroadcastReceiver() {
        override fun onReceive(context: Context, intent: Intent) {
            if (isPlaying && !keepRingingForFullScreenIntent) {
                stop()
            }
        }
    }

    private var screenOffCallkitIncomingBroadcastReceiver =
        ScreenOffCallkitIncomingBroadcastReceiver()

    fun play(data: Bundle) {
        this.isPlaying = true
        this.prepare()
        this.playSound(data)
        this.playVibrator()

        val filter = IntentFilter(Intent.ACTION_SCREEN_OFF)
        context.registerReceiver(screenOffCallkitIncomingBroadcastReceiver, filter)
    }

    fun stop() {
        this.isPlaying = false

        // ✅ Stop MediaPlayer properly
        try {
            mediaPlayer?.stop()
            mediaPlayer?.release()
        } catch (_: Exception) {}
        mediaPlayer = null

        vibrator?.cancel()
        vibrator = null

        // ✅ Restore audio state
        try {
            audioManager?.mode = AudioManager.MODE_NORMAL
        } catch (_: Exception) {}
        audioManager = null

        try {
            context.unregisterReceiver(screenOffCallkitIncomingBroadcastReceiver)
        } catch (_: Exception) {}
    }

    fun destroy() {
        this.isPlaying = false

        try {
            mediaPlayer?.stop()
            mediaPlayer?.release()
        } catch (_: Exception) {}
        mediaPlayer = null

        vibrator?.cancel()
        vibrator = null

        try {
            audioManager?.mode = AudioManager.MODE_NORMAL
        } catch (_: Exception) {}
        audioManager = null

        try {
            context.unregisterReceiver(screenOffCallkitIncomingBroadcastReceiver)
        } catch (_: Exception) {}
    }

    private fun prepare() {
        try {
            mediaPlayer?.stop()
            mediaPlayer?.release()
        } catch (_: Exception) {}
        mediaPlayer = null
        vibrator?.cancel()
    }

    private fun playVibrator() {
        vibrator = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            val vibratorManager =
                context.getSystemService(Context.VIBRATOR_MANAGER_SERVICE) as VibratorManager
            vibratorManager.defaultVibrator
        } else {
            @Suppress("DEPRECATION")
            context.getSystemService(Context.VIBRATOR_SERVICE) as Vibrator
        }

        audioManager = context.getSystemService(Context.AUDIO_SERVICE) as AudioManager
        if (audioManager?.ringerMode == AudioManager.RINGER_MODE_SILENT) return

        val pattern = longArrayOf(0L, 1000L, 1000L)

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val audioAttrs = AudioAttributes.Builder()
                .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
                .setUsage(AudioAttributes.USAGE_NOTIFICATION_RINGTONE)
                .build()
            vibrator?.vibrate(VibrationEffect.createWaveform(pattern, 0), audioAttrs)
        } else {
            @Suppress("DEPRECATION")
            vibrator?.vibrate(pattern, 0)
        }
    }

    private fun playSound(data: Bundle?) {
        val sound = data?.getString(CallkitConstants.EXTRA_CALLKIT_RINGTONE_PATH, "")
        val uri = sound?.let { getRingtoneUri(it) } ?: return

        try {
            audioManager = context.getSystemService(Context.AUDIO_SERVICE) as AudioManager

            // ✅ KEY FIX: Force MODE_NORMAL so audio goes to speaker
            // Agora (and other VoIP SDKs) leave AudioManager in MODE_IN_COMMUNICATION
            // after a call ends. In that mode, STREAM_RING routes to earpiece.
            // We MUST reset to MODE_NORMAL before playing ringtone.
            audioManager?.mode = AudioManager.MODE_NORMAL

            mediaPlayer = MediaPlayer().apply {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
                    setAudioAttributes(
                        AudioAttributes.Builder()
                            .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
                            .setUsage(AudioAttributes.USAGE_VOICE_COMMUNICATION_SIGNALLING)
                            .setLegacyStreamType(AudioManager.STREAM_RING)
                            .build()
                    )
                } else {
                    @Suppress("DEPRECATION")
                    setAudioStreamType(AudioManager.STREAM_RING)
                }

                setDataSource(context, uri)
                isLooping = true
                prepare()
                start()
            }
        } catch (e: Exception) {
            e.printStackTrace()
            // Fallback: try with STREAM_RING if STREAM_MUSIC fails
            try {
                mediaPlayer?.release()
                mediaPlayer = MediaPlayer().apply {
                    @Suppress("DEPRECATION")
                    setAudioStreamType(AudioManager.STREAM_RING)
                    setDataSource(context, uri)
                    isLooping = true
                    prepare()
                    start()
                }
            } catch (e2: Exception) {
                e2.printStackTrace()
            }
        }
    }

    private fun getRingtoneUri(fileName: String): Uri? {
        if (TextUtils.isEmpty(fileName)) return getDefaultRingtoneUri()

        if (fileName.equals("system_ringtone_default", true)) {
            return getDefaultRingtoneUri(useSystemDefault = true)
        }

        return try {
            val resId = context.resources.getIdentifier(fileName, "raw", context.packageName)
            if (resId != 0) {
                Uri.parse("android.resource://${context.packageName}/$resId")
            } else {
                getDefaultRingtoneUri()
            }
        } catch (e: Exception) {
            getDefaultRingtoneUri()
        }
    }

    private fun getDefaultRingtoneUri(useSystemDefault: Boolean = false): Uri? {
        return try {
            if (!useSystemDefault) {
                val resId = context.resources.getIdentifier("ringtone_default", "raw", context.packageName)
                if (resId != 0) {
                    return Uri.parse("android.resource://${context.packageName}/$resId")
                }
            }
            RingtoneManager.getActualDefaultRingtoneUri(context, RingtoneManager.TYPE_RINGTONE)
        } catch (e: Exception) {
            getSafeSystemRingtoneUri()
        }
    }

    private fun getSafeSystemRingtoneUri(): Uri? {
        return try {
            val defaultUri = RingtoneManager.getActualDefaultRingtoneUri(
                context, RingtoneManager.TYPE_RINGTONE
            )
            val rm = RingtoneManager(context)
            rm.setType(RingtoneManager.TYPE_RINGTONE)
            val cursor = rm.cursor
            if (defaultUri != null && cursor != null) {
                while (cursor.moveToNext()) {
                    val uri = rm.getRingtoneUri(cursor.position)
                    if (uri == defaultUri) {
                        cursor.close()
                        return defaultUri
                    }
                }
            }
            if (cursor != null && cursor.moveToFirst()) {
                val fallback = rm.getRingtoneUri(cursor.position)
                cursor.close()
                return fallback
            }
            null
        } catch (e: Exception) {
            e.printStackTrace()
            null
        }
    }

    private var ringingTimer: Timer? = null

    // ✅ FIXED: Timer extended from 500ms to full call duration
    fun keepRingingOnFullScreen(durationMs: Long = 35000L) {
        keepRingingForFullScreenIntent = true
        ringingTimer?.cancel()
        ringingTimer = Timer().apply {
            schedule(object : TimerTask() {
                override fun run() {
                    keepRingingForFullScreenIntent = false
                }
            }, durationMs)
        }
    }
}