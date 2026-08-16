package com.example.legacyapp.music;

import android.content.Context;
import android.content.SharedPreferences;

import java.util.HashSet;
import java.util.Set;

public class FavoritesStore {

    private static final String PREFS_NAME = "music_favorites";
    private static final String KEY_FAVORITE_IDS = "favorite_track_ids";

    private FavoritesStore() {
    }

    public static boolean isFavorite(Context context, long trackId) {
        return favoriteIds(context).contains(String.valueOf(trackId));
    }

    public static void setFavorite(Context context, long trackId, boolean favorite) {
        SharedPreferences prefs = prefs(context);
        Set<String> ids = new HashSet<>(favoriteIds(context));
        String key = String.valueOf(trackId);
        if (favorite) {
            ids.add(key);
        } else {
            ids.remove(key);
        }
        prefs.edit().putStringSet(KEY_FAVORITE_IDS, ids).apply();
    }

    private static Set<String> favoriteIds(Context context) {
        return prefs(context).getStringSet(KEY_FAVORITE_IDS, new HashSet<>());
    }

    private static SharedPreferences prefs(Context context) {
        return context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE);
    }
}
