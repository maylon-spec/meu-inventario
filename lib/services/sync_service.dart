import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/inventory_item.dart';

/// Camada preparada para sincronização. A sincronização só é ativada
/// depois de configurar Firebase, autenticação e regras de segurança.
class SyncService {
  SyncService._();
  static final instance = SyncService._();
  bool enabled = false;

  void configure({required bool enabled}) {
    this.enabled = enabled;
  }

  Future<void> uploadItem(String userId, InventoryItem item) async {
    if (!enabled) return;
    await FirebaseFirestore.instance
        .collection('users').doc(userId)
        .collection('inventory').doc(item.id)
        .set(item.toMap());
  }
}
