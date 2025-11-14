import 'package:flutter/foundation.dart';
import '../../data/models/meditation_model.dart';
import '../../data/repositories/meditation_repository.dart';

class MeditationProvider with ChangeNotifier {
  final MeditationRepository _meditationRepository;

  MeditationProvider(this._meditationRepository);

  // State
  List<MeditationModel> _meditations = [];
  List<MeditationModel> _featuredMeditations = [];
  List<MeditationCategoryModel> _categories = [];
  MeditationModel? _currentMeditation;
  bool _isLoading = false;
  String? _error;

  // Filters
  String? _selectedCategory;
  String? _selectedDifficulty;
  String? _searchQuery;

  // Getters
  List<MeditationModel> get meditations => _meditations;
  List<MeditationModel> get featuredMeditations => _featuredMeditations;
  List<MeditationCategoryModel> get categories => _categories;
  MeditationModel? get currentMeditation => _currentMeditation;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get selectedCategory => _selectedCategory;
  String? get selectedDifficulty => _selectedDifficulty;
  String? get searchQuery => _searchQuery;

  /// Cargar meditaciones
  Future<void> loadMeditations({
    String? category,
    String? difficulty,
    String? search,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _meditations = await _meditationRepository.getMeditations(
        category: category ?? _selectedCategory,
        difficulty: difficulty ?? _selectedDifficulty,
        search: search ?? _searchQuery,
      );

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Cargar meditaciones destacadas
  Future<void> loadFeaturedMeditations() async {
    try {
      _featuredMeditations = await _meditationRepository.getFeaturedMeditations();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  /// Cargar categorías
  Future<void> loadCategories() async {
    try {
      _categories = await _meditationRepository.getCategories();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  /// Obtener detalles de meditación
  Future<void> loadMeditationDetails(String id) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _currentMeditation = await _meditationRepository.getMeditation(id);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Reproducir meditación
  Future<String?> playMeditation(String id) async {
    try {
      final audioUrl = await _meditationRepository.playMeditation(id);
      return audioUrl;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  /// Completar meditación
  Future<MeditationCompletionModel?> completeMeditation({
    required String id,
    int? duration,
  }) async {
    try {
      final completion = await _meditationRepository.completeMeditation(
        id: id,
        duration: duration,
      );
      return completion;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  /// Calificar meditación
  Future<bool> rateMeditation({
    required String id,
    required int rating,
  }) async {
    try {
      return await _meditationRepository.rateMeditation(
        id: id,
        rating: rating,
      );
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Aplicar filtros
  void setCategory(String? category) {
    _selectedCategory = category;
    notifyListeners();
    loadMeditations();
  }

  void setDifficulty(String? difficulty) {
    _selectedDifficulty = difficulty;
    notifyListeners();
    loadMeditations();
  }

  void setSearch(String? search) {
    _searchQuery = search;
    notifyListeners();
    loadMeditations();
  }

  void clearFilters() {
    _selectedCategory = null;
    _selectedDifficulty = null;
    _searchQuery = null;
    notifyListeners();
    loadMeditations();
  }

  /// Limpiar error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
