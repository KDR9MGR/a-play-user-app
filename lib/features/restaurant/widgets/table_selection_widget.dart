import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controller/table_booking_controller.dart';
import '../model/restaurant_table_model.dart';

class TableSelectionWidget extends ConsumerWidget {
  final String restaurantId;
  final DateTime date;
  final int? minCapacity;
  final Function(RestaurantTable) onTableSelected;

  const TableSelectionWidget({
    super.key,
    required this.restaurantId,
    required this.date,
    this.minCapacity,
    required this.onTableSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tablesAsync = ref.watch(restaurantTablesFamily(restaurantId));
    final selectedTable = ref.watch(selectedTableProvider);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Select a Table',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Choose from available tables for your party',
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 24),
          
          Expanded(
            child: tablesAsync.when(
              data: (tables) {
                // Filter tables by minimum capacity if specified
                final filteredTables = minCapacity != null
                    ? tables.where((table) => table.capacity >= minCapacity!).toList()
                    : tables;

                if (filteredTables.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.table_restaurant,
                          size: 64,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          minCapacity != null 
                              ? 'No tables available for $minCapacity+ people'
                              : 'No tables available',
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                // Group tables by type
                final groupedTables = <String, List<RestaurantTable>>{};
                for (final table in filteredTables) {
                  groupedTables.putIfAbsent(table.tableType, () => []).add(table);
                }

                return ListView(
                  children: groupedTables.entries.map((entry) {
                    return _buildTableTypeSection(
                      entry.key,
                      entry.value,
                      selectedTable,
                      onTableSelected,
                    );
                  }).toList(),
                );
              },
              loading: () => const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
                ),
              ),
              error: (error, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Failed to load tables',
                      style: TextStyle(
                        color: Colors.red[400],
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      error.toString(),
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableTypeSection(
    String tableType,
    List<RestaurantTable> tables,
    RestaurantTable? selectedTable,
    Function(RestaurantTable) onTableSelected,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Text(
            tableType.displayName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.2,
          ),
          itemCount: tables.length,
          itemBuilder: (context, index) {
            final table = tables[index];
            final isSelected = selectedTable?.id == table.id;
            
            return GestureDetector(
              onTap: () => onTableSelected(table),
              child: Container(
                decoration: BoxDecoration(
                  color: isSelected ? Colors.orange.withValues(alpha: 0.2) : Colors.grey[800],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? Colors.orange : Colors.grey[700]!,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _getTableIcon(table.tableType),
                      size: 32,
                      color: isSelected ? Colors.orange : Colors.grey[400],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      table.tableNumber,
                      style: TextStyle(
                        color: isSelected ? Colors.orange : Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${table.capacity} seats',
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 12,
                      ),
                    ),
                    if (table.locationDescription != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        table.locationDescription!,
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 10,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        ),
        
        const SizedBox(height: 24),
      ],
    );
  }

  IconData _getTableIcon(String tableType) {
    switch (tableType.toLowerCase()) {
      case 'outdoor':
        return Icons.deck;
      case 'private':
        return Icons.meeting_room;
      case 'bar':
        return Icons.local_bar;
      default:
        return Icons.table_restaurant;
    }
  }
}