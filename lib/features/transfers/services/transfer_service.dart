import 'package:flutter/foundation.dart';
import '../models/transfer_item.dart';

class TransferService extends ChangeNotifier {
  static final TransferService _instance = TransferService._internal();
  factory TransferService() => _instance;
  TransferService._internal();

  final List<TransferItem> _items = [];

  List<TransferItem> get items => List.unmodifiable(_items);

  void addItem(TransferItem item) {
    _items.insert(0, item);
    if (_items.length > 50) {
      _items.removeLast();
    }
    notifyListeners();
  }

  void removeItem(String id) {
    _items.removeWhere((item) => item.id == id);
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}
