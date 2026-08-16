package com.example.legacyapp.music;

import android.content.Context;

public class FavoritesStore {

    private FavoritesStore() {
    }

    public static boolean isFavorite(Context context, long trackId) {
        return FavoritesDbHelper.getInstance(context).isFavorite(trackId);
    }

    public static void setFavorite(Context context, long trackId, boolean favorite) {
        FavoritesDbHelper.getInstance(context).setFavorite(trackId, favorite);
    }
}
