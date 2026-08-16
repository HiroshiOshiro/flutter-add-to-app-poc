package com.example.legacyapp.music;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageButton;
import android.widget.ImageView;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;

import com.example.legacyapp.R;

import java.util.ArrayList;
import java.util.List;

public class TrackAdapter extends RecyclerView.Adapter<TrackAdapter.ViewHolder> {

    public interface OnTrackClickListener {
        void onTrackClicked(ItunesTrack track);
    }

    private final List<ItunesTrack> tracks = new ArrayList<>();
    private final OnTrackClickListener listener;

    public TrackAdapter(OnTrackClickListener listener) {
        this.listener = listener;
    }

    public void submitList(List<ItunesTrack> newTracks) {
        tracks.clear();
        tracks.addAll(newTracks);
        notifyDataSetChanged();
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
        Context context = holder.itemView.getContext();

        holder.trackName.setText(track.trackName);
        holder.artistName.setText(track.artistName);
        ArtworkLoader.loadInto(track.artworkUrl, holder.artwork);

        holder.itemView.setOnClickListener(v -> {
            if (listener != null) {
                listener.onTrackClicked(track);
            }
        });

        updateFavoriteIcon(holder.favoriteButton, context, track.trackId);
        holder.favoriteButton.setOnClickListener(v -> {
            boolean newState = !FavoritesStore.isFavorite(context, track.trackId);
            FavoritesStore.setFavorite(context, track.trackId, newState);
            updateFavoriteIcon(holder.favoriteButton, context, track.trackId);
        });
    }

    private void updateFavoriteIcon(ImageButton button, Context context, long trackId) {
        boolean isFavorite = FavoritesStore.isFavorite(context, trackId);
        button.setImageResource(isFavorite ? R.drawable.ic_favorite_filled : R.drawable.ic_favorite_outline);
    }

    @Override
    public int getItemCount() {
        return tracks.size();
    }

    static class ViewHolder extends RecyclerView.ViewHolder {
        final ImageView artwork;
        final TextView trackName;
        final TextView artistName;
        final ImageButton favoriteButton;

        ViewHolder(@NonNull View itemView) {
            super(itemView);
            artwork = itemView.findViewById(R.id.imageArtwork);
            trackName = itemView.findViewById(R.id.textTrackName);
            artistName = itemView.findViewById(R.id.textArtistName);
            favoriteButton = itemView.findViewById(R.id.buttonFavorite);
        }
    }
}
