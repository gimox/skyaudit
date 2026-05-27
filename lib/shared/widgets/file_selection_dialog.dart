import 'package:flutter/material.dart';
import 'package:travel_check/core/theme/app_theme.dart';
import 'package:travel_check/features/upload/models/log_history.dart';

class FileSelectionDialog extends StatefulWidget {
  final List<LogHistory> logs;
  final Set<String> initialSelected;
  final Function(Set<String>) onSelectedChanged;

  const FileSelectionDialog({
    super.key,
    required this.logs,
    required this.initialSelected,
    required this.onSelectedChanged,
  });

  @override
  State<FileSelectionDialog> createState() => _FileSelectionDialogState();
}

class _FileSelectionDialogState extends State<FileSelectionDialog> {
  late Set<String> _localSelected;
  String _searchQuery = '';
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _localSelected = Set<String>.from(widget.initialSelected);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredLogs = widget.logs.where((log) {
      if (_searchQuery.isEmpty) return true;
      return log.fileName.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 450, maxHeight: 550),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.insert_drive_file_outlined, color: SkyTheme.timBlue),
                const SizedBox(width: 8),
                const Text(
                  'SELEZIONA FILE CARICATI',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // SEARCH FIELD
            Container(
              height: 44,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                children: [
                  const Icon(Icons.search, color: Colors.grey, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: const InputDecoration(
                        hintText: 'Cerca file per nome...',
                        border: InputBorder.none,
                        isDense: true,
                      ),
                      style: const TextStyle(fontSize: 14),
                      onChanged: (val) {
                        setState(() {
                          _searchQuery = val;
                        });
                      },
                    ),
                  ),
                  if (_searchQuery.isNotEmpty)
                    IconButton(
                      icon: const Icon(Icons.clear, size: 18, color: Colors.grey),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {
                          _searchQuery = '';
                        });
                      },
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            // SELECT ALL / DESELECT ALL BUTTONS
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () {
                    setState(() {
                      for (final log in filteredLogs) {
                        _localSelected.add(log.uniqueCode);
                      }
                    });
                  },
                  child: const Text('Seleziona filtrati', style: TextStyle(fontSize: 12, color: SkyTheme.timBlue)),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      for (final log in filteredLogs) {
                        _localSelected.remove(log.uniqueCode);
                      }
                    });
                  },
                  child: const Text('Deseleziona filtrati', style: TextStyle(fontSize: 12, color: Colors.red)),
                ),
              ],
            ),
            const Divider(),
            // SCROLLABLE LIST
            Expanded(
              child: filteredLogs.isEmpty
                  ? Center(
                      child: Text(
                        'Nessun file trovato',
                        style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
                      ),
                    )
                  : ListView.builder(
                      itemCount: filteredLogs.length,
                      itemBuilder: (context, index) {
                        final log = filteredLogs[index];
                        final isChecked = _localSelected.contains(log.uniqueCode);
                        return CheckboxListTile(
                          value: isChecked,
                          title: Text(
                            log.fileName,
                            style: const TextStyle(fontSize: 13),
                          ),
                          subtitle: Text(
                            'Righe: ${log.totalRecords} | ${log.date.day}/${log.date.month}/${log.date.year}',
                            style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                          ),
                          onChanged: (val) {
                            setState(() {
                              if (val == true) {
                                _localSelected.add(log.uniqueCode);
                              } else {
                                _localSelected.remove(log.uniqueCode);
                              }
                            });
                          },
                          controlAffinity: ListTileControlAffinity.leading,
                          contentPadding: EdgeInsets.zero,
                          dense: true,
                          activeColor: SkyTheme.timBlue,
                        );
                      },
                    ),
            ),
            const Divider(),
            const SizedBox(height: 8),
            // BUTTONS
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('Annulla'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      widget.onSelectedChanged(_localSelected);
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      backgroundColor: SkyTheme.timBlue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('Conferma'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
