import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/inventory_item.dart';
import '../services/inventory_database.dart';

class ItemFormScreen extends StatefulWidget {
  final String initialBarcode;
  const ItemFormScreen({super.key, this.initialBarcode = ''});
  @override
  State<ItemFormScreen> createState() => _ItemFormScreenState();
}

class _ItemFormScreenState extends State<ItemFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _barcode = TextEditingController();
  final _quantity = TextEditingController(text: '1');
  final _value = TextEditingController();
  final _notes = TextEditingController();
  String _room = 'Cozinha';
  String _category = 'EletrodomÃ©sticos';

  final _rooms = ['Cozinha', 'Sala', 'Quarto', 'Banheiro', 'Lavanderia',
    'Garagem', 'EscritÃ³rio', 'Ãrea externa', 'Outros'];
  final _categories = ['EletrodomÃ©sticos', 'MÃ³veis', 'EletrÃ´nicos',
    'UtensÃ­lios', 'DecoraÃ§Ã£o', 'Ferramentas', 'Roupas', 'Outros'];

  @override
  void initState() {
    super.initState();
    _barcode.text = widget.initialBarcode;
  }

  @override
  void dispose() {
    _name.dispose(); _barcode.dispose(); _quantity.dispose();
    _value.dispose(); _notes.dispose();
    super.dispose();
  }

  String? _required(String? value) =>
      value == null || value.trim().isEmpty ? 'Campo obrigatÃ³rio' : null;

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final item = InventoryItem(
      id: const Uuid().v4(),
      name: _name.text.trim(),
      category: _category,
      room: _room,
      barcode: _barcode.text.trim(),
      quantity: int.parse(_quantity.text),
      unitValue: double.parse(_value.text.replaceAll(',', '.')),
      notes: _notes.text.trim(),
      updatedAt: DateTime.now(),
    );
    await InventoryDatabase.instance.save(item);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cadastrar item')),
      body: Form(
        key: _formKey,
        child: ListView(padding: const EdgeInsets.all(16), children: [
          TextFormField(controller: _name, decoration: const InputDecoration(
            labelText: 'Nome do item', hintText: 'Ex.: Liquidificador'),
            validator: _required),
          const SizedBox(height: 12),
          DropdownButtonFormField(initialValue: _room, decoration: const InputDecoration(
            labelText: 'CÃ´modo'), items: _rooms.map((v) =>
              DropdownMenuItem(value: v, child: Text(v))).toList(),
            onChanged: (v) => setState(() => _room = v!)),
          const SizedBox(height: 12),
          DropdownButtonFormField(initialValue: _category, decoration: const InputDecoration(
            labelText: 'Categoria'), items: _categories.map((v) =>
              DropdownMenuItem(value: v, child: Text(v))).toList(),
            onChanged: (v) => setState(() => _category = v!)),
          const SizedBox(height: 12),
          TextFormField(controller: _barcode, decoration: const InputDecoration(
            labelText: 'CÃ³digo de barras / etiqueta QR',
            helperText: 'Pode ser preenchido pelo leitor Bluetooth')),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: TextFormField(controller: _quantity,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Quantidade'),
              validator: (v) {
                if (v == null || int.tryParse(v) == null || int.parse(v) < 1) {
                  return 'Informe uma quantidade vÃ¡lida';
                }
                return null;
              })),
            const SizedBox(width: 12),
            Expanded(child: TextFormField(controller: _value,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Valor unitÃ¡rio (R\$)'),
              validator: (v) {
                if (v == null || double.tryParse(v.replaceAll(',', '.')) == null ||
                    double.parse(v.replaceAll(',', '.')) < 0) {
                  return 'Informe um valor vÃ¡lido';
                }
                return null;
              })),
          ]),
          const SizedBox(height: 12),
          TextFormField(controller: _notes, maxLines: 3,
            decoration: const InputDecoration(labelText: 'ObservaÃ§Ãµes (opcional)')),
          const SizedBox(height: 24),
          FilledButton.icon(onPressed: _save,
            icon: const Icon(Icons.save_outlined),
            label: const Text('Salvar item')),
        ]),
      ),
    );
  }
}

