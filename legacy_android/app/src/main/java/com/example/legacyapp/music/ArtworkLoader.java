package com.example.legacyapp.music;

import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.util.LruCache;
import android.widget.ImageView;

import java.io.InputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

public class ArtworkLoader {

    private static final ExecutorService EXECUTOR = Executors.newFixedThreadPool(4);
    private static final LruCache<String, Bitmap> CACHE = new LruCache<>(64);

    private ArtworkLoader() {
    }

    public static void loadInto(String url, ImageView imageView) {
        imageView.setImageBitmap(null);
        if (url == null || url.isEmpty()) {
            return;
        }
        Bitmap cached = CACHE.get(url);
        if (cached != null) {
            imageView.setImageBitmap(cached);
            return;
        }
        imageView.setTag(url);
        EXECUTOR.execute(() -> {
            Bitmap bitmap = downloadBitmap(url);
            if (bitmap != null) {
                CACHE.put(url, bitmap);
                imageView.post(() -> {
                    if (url.equals(imageView.getTag())) {
                        imageView.setImageBitmap(bitmap);
                    }
                });
            }
        });
    }

    private static Bitmap downloadBitmap(String urlString) {
        HttpURLConnection connection = null;
        try {
            URL url = new URL(urlString);
            connection = (HttpURLConnection) url.openConnection();
            connection.setConnectTimeout(10000);
            connection.setReadTimeout(10000);
            try (InputStream input = connection.getInputStream()) {
                return BitmapFactory.decodeStream(input);
            }
        } catch (Exception e) {
            return null;
        } finally {
            if (connection != null) {
                connection.disconnect();
            }
        }
    }
}
