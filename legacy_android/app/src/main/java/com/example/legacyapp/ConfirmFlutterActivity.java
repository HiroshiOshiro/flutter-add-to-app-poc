package com.example.legacyapp;

import android.content.Intent;
import android.os.Bundle;

import androidx.annotation.NonNull;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;

import org.json.JSONException;
import org.json.JSONObject;

import java.io.IOException;
import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.nio.charset.StandardCharsets;
import java.util.HashMap;
import java.util.Map;

public class ConfirmFlutterActivity extends FlutterActivity {

    private static final String CHANNEL_NAME = "com.example.legacyapp/confirm";
    private static final String SUBMIT_URL = "https://jsonplaceholder.typicode.com/posts";

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);

        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL_NAME)
                .setMethodCallHandler((call, result) -> {
                    switch (call.method) {
                        case "getInitialData":
                            result.success(currentFormDataMap());
                            break;
                        case "confirmSubmit":
                            submitInBackground(result);
                            break;
                        case "goToComplete":
                            startActivity(new Intent(this, CompleteActivity.class));
                            finish();
                            result.success(null);
                            break;
                        default:
                            result.notImplemented();
                    }
                });
    }

    private Map<String, String> currentFormDataMap() {
        FormData data = BaseActivity.sFormData;
        Map<String, String> map = new HashMap<>();
        map.put("name", data.name);
        map.put("email", data.email);
        map.put("message", data.message);
        return map;
    }

    private void submitInBackground(MethodChannel.Result result) {
        new Thread(() -> {
            boolean success = postFormData(BaseActivity.sFormData);
            runOnUiThread(() -> result.success(success));
        }).start();
    }

    private boolean postFormData(FormData data) {
        HttpURLConnection connection = null;
        try {
            JSONObject body = new JSONObject();
            body.put("name", data.name);
            body.put("email", data.email);
            body.put("message", data.message);

            URL url = new URL(SUBMIT_URL);
            connection = (HttpURLConnection) url.openConnection();
            connection.setRequestMethod("POST");
            connection.setRequestProperty("Content-Type", "application/json; charset=utf-8");
            connection.setDoOutput(true);
            connection.setConnectTimeout(10000);
            connection.setReadTimeout(10000);

            OutputStream os = connection.getOutputStream();
            try {
                os.write(body.toString().getBytes(StandardCharsets.UTF_8));
            } finally {
                os.close();
            }

            int code = connection.getResponseCode();
            return code >= 200 && code < 300;
        } catch (IOException | JSONException e) {
            return false;
        } finally {
            if (connection != null) {
                connection.disconnect();
            }
        }
    }
}
