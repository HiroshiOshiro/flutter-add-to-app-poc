package com.example.legacyapp.music;

import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.util.LruCache;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;

import com.example.legacyapp.R;

import java.io.InputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

public class TrackAdapter extends RecyclerView.Adapter<TrackAdapter.ViewHolder> {

    private final List<ItunesTrack> tracks = new ArrayList<>();
    private final ExecutorService imageExecutor = Executors.newFixedThreadPool(4);
    private final LruCache<String, Bitmap> artworkCache = new LruCache<>(64);

    public void submitList(List<ItunesTrack> newTracks) {
        tracks.clear();
        tracks.addAll(newTracks);
        notifyDataSetChanged();
    }

    public int getItemCountPublic() {
        return tracks.size();
    }

    @NonNull
    @Override
    public ViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        View view = LayoutInflater.from(parent.getContext()).inflate(R.layout.item_track, parent, false);
        return new ViewHolder(view);
    }

    @Override
    public void onBindViewHolder(@NonNull ViewHolder holder, int position) {
        ItunesTrack track = tracks.get(position);
        holder.trackName.setText(track.trackName);
        holder.artistName.setText(track.artistName);
        holder.artwork.setImageBitmap(null);
        loadArtwork(track.artworkUrl, holder.artwork);
    }

    @Override
    public int getItemCount() {
        return tracks.size();
    }

    private void loadArtwork(String url, ImageView imageView) {
        if (url == null || url.isEmpty()) {
            return;
        }
        Bitmap cached = artworkCache.get(url);
        if (cached != null) {
            imageView.setImageBitmap(cached);
            return;
        }
        imageView.setTag(url);
        imageExecutor.execute(() -> {
            Bitmap bitmap = downloadBitmap(url);
            if (bitmap != null) {
                artworkCache.put(url, bitmap);
                imageView.post(() -> {
                    if (url.equals(imageView.getTag())) {
                        imageView.setImageBitmap(bitmap);
                    }
                });
            }
        });
    }

    private Bitmap downloadBitmap(String urlString) {
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

    static class ViewHolder extends RecyclerView.ViewHolder {
        final ImageView artwork;
        final TextView trackName;
        final TextView artistName;

        ViewHolder(@NonNull View itemView) {
            super(itemView);
            artwork = itemView.findViewById(R.id.imageArtwork);
            trackName = itemView.findViewById(R.id.textTrackName);
            artistName = itemView.findViewById(R.id.textArtistName);
        }
    }
}
