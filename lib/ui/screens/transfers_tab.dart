import 'package:flutter/material.dart';
import '../../features/transfers/models/transfer_item.dart';
import '../../features/transfers/services/transfer_service.dart';
import '../widgets/transfer_feed_item.dart';

class TransfersTab extends StatefulWidget {
  const TransfersTab({Key? key}) : super(key: key);

  @override
  State<TransfersTab> createState() => _TransfersTabState();
}

class _TransfersTabState extends State<TransfersTab> {
  final TransferService _transfers = TransferService();
  String _selectedFilter = 'all'; // 'all', 'text', 'photo', 'file'

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _transfers,
      builder: (context, _) {
        final allItems = _transfers.items;
        final filteredItems = allItems.where((item) {
          if (_selectedFilter == 'text') return item.type == TransferType.text;
          if (_selectedFilter == 'photo') return item.type == TransferType.photo;
          if (_selectedFilter == 'file') return item.type == TransferType.file;
          return true;
        }).toList();

        return Column(
          children: [
            // Filter chips header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              color: const Color(0xFF0F172A),
              child: Row(
                children: [
                  _FilterChip(
                    label: 'Todos (${allItems.length})',
                    isSelected: _selectedFilter == 'all',
                    onTap: () => setState(() => _selectedFilter = 'all'),
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: '📋 Textos',
                    isSelected: _selectedFilter == 'text',
                    onTap: () => setState(() => _selectedFilter = 'text'),
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: '📁 Mídia & Arquivos',
                    isSelected: _selectedFilter == 'photo' || _selectedFilter == 'file',
                    onTap: () => setState(() => _selectedFilter = _selectedFilter == 'photo' ? 'file' : 'photo'),
                  ),
                  const Spacer(),
                  if (allItems.isNotEmpty)
                    IconButton(
                      icon: const Icon(Icons.delete_sweep_outlined, color: Colors.white54, size: 20),
                      tooltip: 'Limpar Histórico',
                      onPressed: () => _transfers.clear(),
                    ),
                ],
              ),
            ),

            // Transfer list
            Expanded(
              child: filteredItems.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.history_rounded, size: 48, color: Colors.grey[700]),
                          const SizedBox(height: 12),
                          Text(
                            allItems.isEmpty
                                ? 'Nenhuma transferência ainda'
                                : 'Nenhum item com este filtro',
                            style: const TextStyle(color: Colors.white70, fontSize: 15),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            allItems.isEmpty
                                ? 'Copie um texto no PC ou envie um arquivo para ver aqui.'
                                : 'Alterne o filtro acima para ver outros eventos.',
                            style: TextStyle(color: Colors.grey[500], fontSize: 13),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.only(top: 8, bottom: 24),
                      itemCount: filteredItems.length,
                      itemBuilder: (ctx, index) {
                        return TransferFeedItem(item: filteredItems[index]);
                      },
                    ),
            ),
          ],
        );
      },
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF06B6D4) : const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? const Color(0xFF06B6D4) : const Color(0xFF334155),
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? const Color(0xFF0F172A) : Colors.white70,
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
