package com.example.legacyapp;

import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import android.widget.TextView;
import android.widget.Toast;

import org.json.JSONException;
import org.json.JSONObject;

import java.io.IOException;
import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.nio.charset.StandardCharsets;

public class ConfirmActivity extends BaseActivity {

    private static final String SUBMIT_URL = "https://jsonplaceholder.typicode.com/posts";

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_confirm);

        ((TextView) findViewById(R.id.textName)).setText(sFormData.name);
        ((TextView) findViewById(R.id.textEmail)).setText(sFormData.email);
        ((TextView) findViewById(R.id.textMessage)).setText(sFormData.message);

        findViewById(R.id.buttonConfirm).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                submit();
            }
        });
    }

    private void submit() {
        final View button = findViewById(R.id.buttonConfirm);
        button.setEnabled(false);

        new Thread(new Runnable() {
            @Override
            public void run() {
                final boolean success = postFormData(sFormData);
                runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        button.setEnabled(true);
                        if (success) {
                            startActivity(new Intent(ConfirmActivity.this, CompleteActivity.class));
                        } else {
                            Toast.makeText(ConfirmActivity.this, R.string.submit_failed, Toast.LENGTH_SHORT).show();
                        }
                    }
                });
            }
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
