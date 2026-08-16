package com.example.legacyapp.music;

import android.content.ContentValues;
import android.content.Context;
import android.database.Cursor;
import android.database.sqlite.SQLiteDatabase;
import android.database.sqlite.SQLiteOpenHelper;

public class FavoritesDbHelper extends SQLiteOpenHelper {

    private static final String DB_NAME = "music_favorites.db";
    private static final int DB_VERSION = 1;
    private static final String TABLE_FAVORITES = "favorites";
    private static final String COLUMN_TRACK_ID = "track_id";

    private static FavoritesDbHelper instance;

    public static synchronized FavoritesDbHelper getInstance(Context context) {
        if (instance == null) {
            instance = new FavoritesDbHelper(context.getApplicationContext());
        }
        return instance;
    }

    private FavoritesDbHelper(Context context) {
        super(context, DB_NAME, null, DB_VERSION);
    }

    @Override
    public void onCreate(SQLiteDatabase db) {
        db.execSQL("CREATE TABLE " + TABLE_FAVORITES + " (" + COLUMN_TRACK_ID + " INTEGER PRIMARY KEY)");
    }

    @Override
    public void onUpgrade(SQLiteDatabase db, int oldVersion, int newVersion) {
        db.execSQL("DROP TABLE IF EXISTS " + TABLE_FAVORITES);
        onCreate(db);
    }

    public boolean isFavorite(long trackId) {
        SQLiteDatabase db = getReadableDatabase();
        try (Cursor cursor = db.query(TABLE_FAVORITES, new String[]{COLUMN_TRACK_ID},
                COLUMN_TRACK_ID + " = ?", new String[]{String.valueOf(trackId)}, null, null, null)) {
            return cursor.getCount() > 0;
        }
    }

    public void setFavorite(long trackId, boolean favorite) {
        SQLiteDatabase db = getWritableDatabase();
        if (favorite) {
            ContentValues values = new ContentValues();
            values.put(COLUMN_TRACK_ID, trackId);
            db.insertWithOnConflict(TABLE_FAVORITES, null, values, SQLiteDatabase.CONFLICT_REPLACE);
        } else {
            db.delete(TABLE_FAVORITES, COLUMN_TRACK_ID + " = ?", new String[]{String.valueOf(trackId)});
        }
    }
}
