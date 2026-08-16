package com.example.legacyapp;

import android.content.Intent;
import android.net.Uri;
import android.os.Bundle;
import android.text.TextUtils;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.inputmethod.EditorInfo;
import android.widget.EditText;
import android.widget.TextView;
import android.widget.Toast;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.fragment.app.Fragment;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.example.legacyapp.music.ItunesTrack;
import com.example.legacyapp.music.TrackAdapter;

import org.json.JSONArray;
import org.json.JSONObject;

import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.URL;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.List;

public class MusicFragment extends Fragment {

    private static final String SEARCH_URL = "https://itunes.apple.com/search";

    private EditText searchQuery;
    private TextView emptyState;
    private TrackAdapter adapter;

    @Nullable
    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container, @Nullable Bundle savedInstanceState) {
        return inflater.inflate(R.layout.fragment_music, container, false);
    }

    @Override
    public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);

        searchQuery = view.findViewById(R.id.editSearchQuery);
        emptyState = view.findViewById(R.id.textEmptyState);
        RecyclerView recyclerView = view.findViewById(R.id.recyclerResults);

        adapter = new TrackAdapter(track -> {
            Intent intent = new Intent(requireContext(), TrackDetailActivity.class);
            intent.putExtra(TrackDetailActivity.EXTRA_TRACK_ID, track.trackId);
            intent.putExtra(TrackDetailActivity.EXTRA_TRACK_NAME, track.trackName);
            intent.putExtra(TrackDetailActivity.EXTRA_ARTIST_NAME, track.artistName);
            intent.putExtra(TrackDetailActivity.EXTRA_COLLECTION_NAME, track.collectionName);
            intent.putExtra(TrackDetailActivity.EXTRA_GENRE_NAME, track.primaryGenreName);
            intent.putExtra(TrackDetailActivity.EXTRA_ARTWORK_URL, track.artworkUrlLarge);
            startActivity(intent);
        });
        recyclerView.setLayoutManager(new LinearLayoutManager(requireContext()));
        recyclerView.setAdapter(adapter);

        view.findViewById(R.id.buttonSearch).setOnClickListener(v -> performSearch());
        searchQuery.setOnEditorActionListener((v, actionId, event) -> {
            if (actionId == EditorInfo.IME_ACTION_SEARCH) {
                performSearch();
                return true;
            }
            return false;
        });
    }

    @Override
    public void onResume() {
        super.onResume();
        // Favorite state may have changed on the detail screen; refresh the
        // star icons now that this list is visible again.
        if (adapter != null) {
            adapter.notifyDataSetChanged();
        }
    }

    private void performSearch() {
        String term = searchQuery.getText().toString().trim();
        if (TextUtils.isEmpty(term)) {
            return;
        }
        emptyState.setVisibility(View.GONE);

        new Thread(() -> {
            List<ItunesTrack> results = fetchResults(term);
            if (getActivity() == null) {
                return;
            }
            getActivity().runOnUiThread(() -> {
                if (results == null) {
                    Toast.makeText(requireContext(), R.string.music_search_error, Toast.LENGTH_SHORT).show();
                    return;
                }
                adapter.submitList(results);
                if (results.isEmpty()) {
                    emptyState.setText(R.string.music_no_results);
                    emptyState.setVisibility(View.VISIBLE);
                } else {
                    emptyState.setVisibility(View.GONE);
                }
            });
        }).start();
    }

    private List<ItunesTrack> fetchResults(String term) {
        HttpURLConnection connection = null;
        try {
            Uri uri = Uri.parse(SEARCH_URL).buildUpon()
                    .appendQueryParameter("term", term)
                    .appendQueryParameter("media", "music")
                    .appendQueryParameter("limit", "25")
                    .build();
            URL url = new URL(uri.toString());
            connection = (HttpURLConnection) url.openConnection();
            connection.setRequestMethod("GET");
            connection.setConnectTimeout(10000);
            connection.setReadTimeout(10000);

            StringBuilder body = new StringBuilder();
            try (BufferedReader reader = new BufferedReader(
                    new InputStreamReader(connection.getInputStream(), StandardCharsets.UTF_8))) {
                String line;
                while ((line = reader.readLine()) != null) {
                    body.append(line);
                }
            }

            JSONObject json = new JSONObject(body.toString());
            JSONArray results = json.getJSONArray("results");
            List<ItunesTrack> tracks = new ArrayList<>();
            for (int i = 0; i < results.length(); i++) {
                JSONObject item = results.getJSONObject(i);
                ItunesTrack track = new ItunesTrack();
                track.trackId = item.optLong("trackId");
                track.trackName = item.optString("trackName", "");
                track.artistName = item.optString("artistName", "");
                track.collectionName = item.optString("collectionName", "");
                track.primaryGenreName = item.optString("primaryGenreName", "");
                track.artworkUrl = item.optString("artworkUrl60", "");
                track.artworkUrlLarge = item.optString("artworkUrl100", "");
                tracks.add(track);
            }
            return tracks;
        } catch (Exception e) {
            return null;
        } finally {
            if (connection != null) {
                connection.disconnect();
            }
        }
    }
}
