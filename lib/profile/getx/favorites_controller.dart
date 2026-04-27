import 'package:get/get.dart';
import '../model/favorite_model.dart';

class FavoritesController extends GetxController {
  
  var favorites = <FavoriteItem>[].obs;

  String _normalizeId(String id) {
    return id.toString().trim();
  }
  
  void addFavorite(FavoriteItem item) {
  final normalizedId = _normalizeId(item.id);
  if (normalizedId.isEmpty) return;

  final normalizedItem = FavoriteItem(
    id: normalizedId,
    title: item.title,
    image: item.image,
    videoTrailer: item.videoTrailer,
    subtitle: item.subtitle,
    videoMovies: item.videoMovies,
    logoImage: item.logoImage,
    description: item.description,
    imdbRating: item.imdbRating,
    ageRating: item.ageRating,
    directorInfo: item.directorInfo,
    castInfo: item.castInfo,
    tagline: item.tagline,
    fullStoryline: item.fullStoryline,
    genres: item.genres,
    tags: item.tags,
    language: item.language,
    duration: item.duration,
    releaseYear: item.releaseYear,
  );

  final isFav = favorites.any((e) => _normalizeId(e.id) == normalizedId);
  if (!isFav) {
    favorites.add(normalizedItem);
  }
  favorites.refresh();
}

  void removeFavorite(String id) {
    final normalizedId = _normalizeId(id);
    favorites.removeWhere((e) => _normalizeId(e.id) == normalizedId);
    print("❌ Removed from favorites: $normalizedId");
    favorites.refresh();
  }

  void toggleFavorite(FavoriteItem item) {
    final normalizedId = _normalizeId(item.id);
    if (normalizedId.isEmpty) {
      print("❌ ERROR: Cannot toggle favorite - ID is empty");
      return;
    }
    
    if (isFavorite(normalizedId)) {
      removeFavorite(normalizedId);
    } else {
      addFavorite(item);
    }
  }

  bool isFavorite(String id) {
    final normalizedId = _normalizeId(id);
    if (normalizedId.isEmpty) return false;
    return favorites.any((e) => _normalizeId(e.id) == normalizedId);
  }
  bool containsItem(FavoriteItem item) {
    final normalizedId = _normalizeId(item.id);
    return favorites.any((e) => _normalizeId(e.id) == normalizedId);
  }
  
  void clearAllFavorites() {
    favorites.clear();
    print("🗑️ All favorites cleared");
    favorites.refresh();
  }
  
  FavoriteItem? getFavoriteById(String id) {
    final normalizedId = _normalizeId(id);
    try {
      return favorites.firstWhere((e) => _normalizeId(e.id) == normalizedId);
    } catch (e) {
      return null;
    }
  }
}