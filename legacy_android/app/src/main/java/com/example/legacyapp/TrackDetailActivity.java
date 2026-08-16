package com.example.legacyapp;

import android.os.Bundle;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.TextView;

import androidx.appcompat.app.AppCompatActivity;

import com.example.legacyapp.music.ArtworkLoader;
import com.example.legacyapp.music.FavoritesStore;

public class TrackDetailActivity extends AppCompatActivity {

    public static final String EXTRA_TRACK_ID = "track_id";
    public static final String EXTRA_TRACK_NAME = "track_name";
    public static final String EXTRA_ARTIST_NAME = "artist_name";
    public static final String EXTRA_COLLECTION_NAME = "collection_name";
    public static final String EXTRA_GENRE_NAME = "genre_name";
    public static final String EXTRA_ARTWORK_URL = "artwork_url";

    private long trackId;
    private Button favoriteButton;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_track_detail);
        setTitle(R.string.detail_title);

        trackId = getIntent().getLongExtra(EXTRA_TRACK_ID, 0);
        String trackName = getIntent().getStringExtra(EXTRA_TRACK_NAME);
        String artistName = getIntent().getStringExtra(EXTRA_ARTIST_NAME);
        String collectionName = getIntent().getStringExtra(EXTRA_COLLECTION_NAME);
        String genreName = getIntent().getStringExtra(EXTRA_GENRE_NAME);
        String artworkUrl = getIntent().getStringExtra(EXTRA_ARTWORK_URL);

        ((TextView) findViewById(R.id.textTrackName)).setText(trackName);
        ((TextView) findViewById(R.id.textArtistName)).setText(artistName);
        ((TextView) findViewById(R.id.textAlbum)).setText(collectionName);
        ((TextView) findViewById(R.id.textGenre)).setText(genreName);
        ArtworkLoader.loadInto(artworkUrl, (ImageView) findViewById(R.id.imageArtwork));

        favoriteButton = findViewById(R.id.buttonFavorite);
        updateFavoriteButton();
        favoriteButton.setOnClickListener(v -> {
            boolean newState = !FavoritesStore.isFavorite(this, trackId);
            FavoritesStore.setFavorite(this, trackId, newState);
            updateFavoriteButton();
        });
    }

    private void updateFavoriteButton() {
        boolean isFavorite = FavoritesStore.isFavorite(this, trackId);
        favoriteButton.setText(isFavorite ? R.string.action_remove_favorite : R.string.action_add_favorite);
    }
}
