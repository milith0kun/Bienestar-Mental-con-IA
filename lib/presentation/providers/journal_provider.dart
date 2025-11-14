import 'package:flutter/foundation.dart';
import '../../data/models/journal_entry_model.dart';
import '../../data/repositories/journal_repository.dart';

class JournalProvider with ChangeNotifier {
  final JournalRepository _journalRepository;

  JournalProvider(this._journalRepository);

  // State
  List<JournalEntryModel> _entries = [];
  JournalStatsModel? _stats;
  bool _isLoading = false;
  String? _error;
  int _currentPage = 1;
  bool _hasMore = true;

  // Getters
  List<JournalEntryModel> get entries => _entries;
  JournalStatsModel? get stats => _stats;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasMore => _hasMore;
  bool get canCreateMore => _stats?.canCreateMore ?? true;
  dynamic get remainingEntries => _stats?.remaining;

  /// Crear nueva entrada
  Future<JournalEntryModel?> createEntry({
    required String title,
    required String content,
    required String mood,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final entry = await _journalRepository.createEntry(
        title: title,
        content: content,
        mood: mood,
      );

      _entries.insert(0, entry);
      await loadStats(); // Actualizar estadísticas

      _isLoading = false;
      notifyListeners();
      return entry;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  /// Cargar entradas
  Future<void> loadEntries({bool refresh = false}) async {
    try {
      if (refresh) {
        _currentPage = 1;
        _entries.clear();
        _hasMore = true;
      }

      _isLoading = true;
      _error = null;
      notifyListeners();

      final newEntries = await _journalRepository.getEntries(
        page: _currentPage,
        limit: 10,
      );

      if (newEntries.isEmpty) {
        _hasMore = false;
      } else {
        if (refresh) {
          _entries = newEntries;
        } else {
          _entries.addAll(newEntries);
        }
        _currentPage++;
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Obtener una entrada específica
  Future<JournalEntryModel?> getEntry(String id) async {
    try {
      return await _journalRepository.getEntry(id);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  /// Actualizar entrada
  Future<bool> updateEntry({
    required String id,
    String? title,
    String? content,
    String? mood,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      final updatedEntry = await _journalRepository.updateEntry(
        id: id,
        title: title,
        content: content,
        mood: mood,
      );

      final index = _entries.indexWhere((e) => e.id == id);
      if (index != -1) {
        _entries[index] = updatedEntry;
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Eliminar entrada
  Future<bool> deleteEntry(String id) async {
    try {
      _isLoading = true;
      notifyListeners();

      final success = await _journalRepository.deleteEntry(id);

      if (success) {
        _entries.removeWhere((e) => e.id == id);
        await loadStats();
      }

      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Cargar estadísticas
  Future<void> loadStats() async {
    try {
      _stats = await _journalRepository.getStats();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  /// Limpiar error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
