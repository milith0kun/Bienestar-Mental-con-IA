import 'package:flutter/foundation.dart';
import '../../data/models/mood_log_model.dart';
import '../../data/repositories/mood_repository.dart';

class MoodProvider with ChangeNotifier {
  final MoodRepository _moodRepository;

  MoodProvider(this._moodRepository);

  // State
  List<MoodLogModel> _logs = [];
  MoodLogModel? _todayLog;
  MoodStatsModel? _stats;
  bool _isLoading = false;
  String? _error;

  // Getters
  List<MoodLogModel> get logs => _logs;
  MoodLogModel? get todayLog => _todayLog;
  MoodStatsModel? get stats => _stats;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasLoggedToday => _todayLog != null;

  /// Crear o actualizar registro de estado de ánimo
  Future<bool> createMoodLog({
    required int mood,
    List<String>? emotions,
    String? notes,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final log = await _moodRepository.createMoodLog(
        mood: mood,
        emotions: emotions,
        notes: notes,
      );

      _todayLog = log;
      await loadMoodLogs();

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

  /// Cargar registros de estado de ánimo
  Future<void> loadMoodLogs({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _logs = await _moodRepository.getMoodLogs(
        startDate: startDate,
        endDate: endDate,
      );

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Cargar estadísticas
  Future<void> loadStats({int days = 7}) async {
    try {
      _stats = await _moodRepository.getMoodStats(days: days);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  /// Cargar registro de hoy
  Future<void> loadTodayMood() async {
    try {
      _todayLog = await _moodRepository.getTodayMood();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  /// Eliminar registro
  Future<bool> deleteMoodLog(String id) async {
    try {
      _isLoading = true;
      notifyListeners();

      final success = await _moodRepository.deleteMoodLog(id);

      if (success) {
        _logs.removeWhere((log) => log.id == id);
        if (_todayLog?.id == id) {
          _todayLog = null;
        }
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

  /// Limpiar error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
