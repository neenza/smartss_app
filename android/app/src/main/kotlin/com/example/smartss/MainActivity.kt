package com.example.smartss

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.graphics.drawable.BitmapDrawable
import android.graphics.Bitmap
import android.util.Base64
import java.io.ByteArrayOutputStream

class MainActivity : FlutterActivity() {
    private val CHANNEL = "app.package/resolve"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "getAppInfo") {
                val packageName = call.argument<String>("package")
                if (packageName != null) {
                    try {
                        val pm = packageManager
                        val appInfo = if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.TIRAMISU) {
                            pm.getApplicationInfo(packageName, android.content.pm.PackageManager.ApplicationInfoFlags.of(android.content.pm.PackageManager.GET_META_DATA.toLong()))
                        } else {
                            pm.getApplicationInfo(packageName, 0)
                        }
                        val appName = try {
                            pm.getApplicationLabel(appInfo).toString()
                        } catch (e: Exception) {
                            packageName
                        }
                        val icon = try {
                            pm.getApplicationIcon(appInfo)
                        } catch (e: Exception) {
                            null
                        }
                        var iconBase64: String? = null
                        if (icon != null) {
                            try {
                                val bitmap = if (icon is BitmapDrawable) {
                                    icon.bitmap
                                } else {
                                    val bmp = Bitmap.createBitmap(
                                        icon.intrinsicWidth,
                                        icon.intrinsicHeight,
                                        Bitmap.Config.ARGB_8888
                                    )
                                    val canvas = android.graphics.Canvas(bmp)
                                    icon.setBounds(0, 0, canvas.width, canvas.height)
                                    icon.draw(canvas)
                                    bmp
                                }
                                val stream = ByteArrayOutputStream()
                                bitmap.compress(Bitmap.CompressFormat.PNG, 100, stream)
                                iconBase64 = Base64.encodeToString(stream.toByteArray(), Base64.NO_WRAP)
                            } catch (e: Exception) {
                                iconBase64 = null
                            }
                        }
                        result.success(mapOf("appName" to appName, "iconBase64" to iconBase64))
                    } catch (e: Exception) {
                        result.success(mapOf("appName" to packageName, "iconBase64" to null))
                    }
                } else {
                    result.error("INVALID", "Package name required", null)
                }
            }
        }
    }
}
