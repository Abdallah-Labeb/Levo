package com.levo.app.levo

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "com.levo.app/display")
            .setMethodCallHandler { call, result ->
                if (call.method == "getPhysicalDpi") {
                    val metrics = resources.displayMetrics
                    // ponytail: ydpi is the real physical vertical DPI from the panel spec
                    result.success(metrics.ydpi.toDouble())
                } else {
                    result.notImplemented()
                }
            }
    }
}
