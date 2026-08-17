class Track {
  const Track({
    required this.trackId,
    required this.trackName,
    required this.artistName,
    required this.collectionName,
    required this.primaryGenreName,
    required this.artworkUrl,
    required this.artworkUrlLarge,
  });

  final int trackId;
  final String trackName;
  final String artistName;
  final String collectionName;
  final String primaryGenreName;
  final String artworkUrl;
  final String artworkUrlLarge;
}
