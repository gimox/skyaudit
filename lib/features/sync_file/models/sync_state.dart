class SyncState {
  final String selectedSyncType;
  final bool clearBeforeSync;
  final bool alignWithRemote;
  final bool isSyncing;
  final double syncProgress;
  final String syncStep;
  final List<String> syncLogs;
  final bool showAdvancedConsole;
  final int totalFilesFound;
  final int processedFilesCount;
  final int totalRecordsImported;
  final String currentFile;
  final String currentFileStatus;
  final int currentFileRecords;
  final List<Map<String, dynamic>> syncQueue;

  SyncState({
    required this.selectedSyncType,
    required this.clearBeforeSync,
    required this.alignWithRemote,
    required this.isSyncing,
    required this.syncProgress,
    required this.syncStep,
    required this.syncLogs,
    required this.showAdvancedConsole,
    required this.totalFilesFound,
    required this.processedFilesCount,
    required this.totalRecordsImported,
    required this.currentFile,
    required this.currentFileStatus,
    required this.currentFileRecords,
    required this.syncQueue,
  });

  factory SyncState.initial({
    bool alignWithRemote = true,
    bool clearBeforeSync = false,
  }) {
    return SyncState(
      selectedSyncType: 'all',
      clearBeforeSync: clearBeforeSync,
      alignWithRemote: alignWithRemote,
      isSyncing: false,
      syncProgress: 0.0,
      syncStep: '',
      syncLogs: const [],
      showAdvancedConsole: false,
      totalFilesFound: 0,
      processedFilesCount: 0,
      totalRecordsImported: 0,
      currentFile: '',
      currentFileStatus: '',
      currentFileRecords: 0,
      syncQueue: const [],
    );
  }

  SyncState copyWith({
    String? selectedSyncType,
    bool? clearBeforeSync,
    bool? alignWithRemote,
    bool? isSyncing,
    double? syncProgress,
    String? syncStep,
    List<String>? syncLogs,
    bool? showAdvancedConsole,
    int? totalFilesFound,
    int? processedFilesCount,
    int? totalRecordsImported,
    String? currentFile,
    String? currentFileStatus,
    int? currentFileRecords,
    List<Map<String, dynamic>>? syncQueue,
  }) {
    return SyncState(
      selectedSyncType: selectedSyncType ?? this.selectedSyncType,
      clearBeforeSync: clearBeforeSync ?? this.clearBeforeSync,
      alignWithRemote: alignWithRemote ?? this.alignWithRemote,
      isSyncing: isSyncing ?? this.isSyncing,
      syncProgress: syncProgress ?? this.syncProgress,
      syncStep: syncStep ?? this.syncStep,
      syncLogs: syncLogs ?? this.syncLogs,
      showAdvancedConsole: showAdvancedConsole ?? this.showAdvancedConsole,
      totalFilesFound: totalFilesFound ?? this.totalFilesFound,
      processedFilesCount: processedFilesCount ?? this.processedFilesCount,
      totalRecordsImported: totalRecordsImported ?? this.totalRecordsImported,
      currentFile: currentFile ?? this.currentFile,
      currentFileStatus: currentFileStatus ?? this.currentFileStatus,
      currentFileRecords: currentFileRecords ?? this.currentFileRecords,
      syncQueue: syncQueue ?? this.syncQueue,
    );
  }
}
