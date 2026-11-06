import 'package:flutter/material.dart';
import '../models/inventory_item.dart';
import '../services/inventory_database.dart';
import '../services/scan_feedback.dart';
import 'item_form_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _scanController = TextEditingController();
  final _scanFocus = FocusNode();
  List<InventoryItem> _items = [];
  double _total = 0;
  String _message = 'Conecte seu leitor Bluetooth e faça uma leitura.';
  bool _scanMode = true;

  @override
  void initState() {
    super.initState();
    _refresh();
    WidgetsBinding.instance.addPostFrameCallback((_) => _scanFocus.requestFocus());
  }

  @override
  void dispose() {
    _scanController.dispose();
    _scanFocus.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    final items = await InventoryDatabase.instance.all();
    final total = await InventoryDatabase.instance.totalValue();
    if (!mounted) return;
    setState(() { _items = items; _total = total; });
  }

  Future<void> _onScan(String raw) async {
    final code = raw.trim();
    if (code.isEmpty) return;
    _scanController.clear();
    final existing = await InventoryDatabase.instance.byBarcode(code);
    await ScanFeedback.instance.successBeep();
    if (!mounted) return;

    if (existing != null) {
      setState(() => _message =
          'Código reconhecido: ${existing.name} • ${existing.room}');
      // Nesta primeira versão, a leitura identifica o item. A movimentação
      // automática de quantidade será configurável numa próxima etapa.
    } else {
      setState(() => _message = 'Código $code ainda não cadastrado. Cadastre o item.');
      await _openForm(barcode: code);
    }
    await _refresh();
    if (mounted) _scanFocus.requestFocus();
  }

  Future<void> _openForm({String barcode = ''}) async {
    await Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => ItemFormScreen(initialBarcode: barcode)));
    await _refresh();
    if (mounted) _scanFocus.requestFocus();
  }

  Future<void> _remove(InventoryItem item) async {
    await InventoryDatabase.instance.delete(item.id);
    await _refresh();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meu Inventário', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            tooltip: 'Adicionar item',
            onPressed: () => _openForm(),
            icon: const Icon(Icons.add_circle_outline),
          ),
        ],
      ),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xFF246B5A),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Valor estimado dos seus bens',
                  style: TextStyle(color: Colors.white70)),
              const SizedBox(height: 8),
              Text(_total.toStringAsFixed(2).replaceAll('.', ','),
                  style: const TextStyle(color: Colors.white, fontSize: 30,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text('${_items.length} itens cadastrados',
                  style: const TextStyle(color: Colors.white70)),
            ]),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  const Icon(Icons.bluetooth, color: Color(0xFF246B5A)),
                  const SizedBox(width: 8),
                  const Expanded(child: Text('Leitor Bluetooth (modo teclado)',
                      style: TextStyle(fontWeight: FontWeight.w600))),
                  Switch(value: _scanMode, onChanged: (v) {
                    setState(() => _scanMode = v);
                    if (v) _scanFocus.requestFocus();
                  }),
                ]),
                if (_scanMode)
                  TextField(
                    controller: _scanController,
                    focusNode: _scanFocus,
                    autofocus: true,
                    decoration: const InputDecoration(
                      hintText: 'Leia um código de barras aqui',
                      prefixIcon: Icon(Icons.qr_code_scanner),
                      isDense: true,
                    ),
                    onSubmitted: _onScan,
                  ),
                const SizedBox(height: 8),
                Text(_message, style: Theme.of(context).textTheme.bodySmall),
              ]),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Row(children: [
            Text('Itens da residência', style: Theme.of(context).textTheme.titleMedium),
            const Spacer(),
            TextButton.icon(
              onPressed: () => _openForm(),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Cadastrar'),
            ),
          ]),
        ),
        Expanded(
          child: _items.isEmpty
            ? const Center(child: Text('Nenhum item cadastrado ainda.'))
            : ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                itemCount: _items.length,
                itemBuilder: (context, index) {
                  final item = _items[index];
                  return Card(
                    child: ListTile(
                      leading: CircleAvatar(
                        child: Icon(item.category.toLowerCase().contains('eletro')
                            ? Icons.kitchen : Icons.inventory_2_outlined)),
                      title: Text(item.name),
                      subtitle: Text('${item.room} • Qtd: ${item.quantity}'
                          '${item.barcode.isNotEmpty ? '\nCódigo: ${item.barcode}' : ''}'),
                      isThreeLine: item.barcode.isNotEmpty,
                      trailing: Column(mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end, children: [
                          Text('R\$ ${item.totalValue.toStringAsFixed(2)}',
                              style: const TextStyle(fontWeight: FontWeight.bold)),
                          IconButton(
                            visualDensity: VisualDensity.compact,
                            icon: const Icon(Icons.delete_outline, size: 18),
                            onPressed: () => _remove(item),
                          ),
                        ]),
                      onTap: () => _openForm(barcode: item.barcode),
                    ),
                  );
                },
              ),
        ),
      ]),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(),
        icon: const Icon(Icons.add),
        label: const Text('Novo item'),
      ),
    );
  }
}
