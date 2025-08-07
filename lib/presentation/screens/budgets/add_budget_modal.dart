import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../presentation/providers/budget_provider.dart';
import '../../../data/models/budget_model.dart';

class AddBudgetModal extends StatefulWidget {
  final BudgetModel? budget;
  const AddBudgetModal({super.key, this.budget});

  @override
  State<AddBudgetModal> createState() => _AddBudgetModalState();
}

class _AddBudgetModalState extends State<AddBudgetModal> {
  final _formKey = GlobalKey<FormState>();
  String _category = "Food & Drink";
  final _limitController = TextEditingController();
  DateTime _selectedMonth = DateTime(DateTime.now().year, DateTime.now().month);

  @override
  void initState() {
    super.initState();
    if (widget.budget != null) {
      _category = widget.budget!.category;
      _limitController.text = widget.budget!.limit.toString();
      _selectedMonth = widget.budget!.month;
    }
  }

  @override
  void dispose() {
    _limitController.dispose();
    super.dispose();
  }

  void _pickMonth() async {
    final today = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedMonth,
      firstDate: DateTime(today.year - 2, 1),
      lastDate: DateTime(today.year + 5, 12),
      helpText: "Select Budget Month",
      fieldLabelText: "Budget Month",
      initialDatePickerMode: DatePickerMode.year,
    );
    if (picked != null) {
      setState(() {
        _selectedMonth = DateTime(picked.year, picked.month);
      });
    }
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      final provider = Provider.of<BudgetProvider>(context, listen: false);
      final budget = BudgetModel(
        id: widget.budget?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        category: _category,
        limit: double.parse(_limitController.text),
        spent: widget.budget?.spent ?? 0,
        month: _selectedMonth,
      );
      if (widget.budget == null) {
        provider.addBudget(budget);
      } else {
        provider.updateBudget(budget);
      }
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final categories = [
      'Food & Drink',
      'Transport',
      'Shopping',
      'Salary',
      'Bills',
      'Others',
    ];
    return Padding(
      padding: MediaQuery.of(context).viewInsets,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(widget.budget == null ? "Add Budget" : "Edit Budget",
                  style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _category,
                items: categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (v) => setState(() => _category = v!),
                decoration: const InputDecoration(labelText: "Category"),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _limitController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: "Budget Limit"),
                validator: (v) {
                  if (v == null || v.isEmpty) return "Enter budget limit";
                  final val = double.tryParse(v);
                  if (val == null || val <= 0) return "Enter a valid amount";
                  return null;
                },
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Text(
                    "Month: ${_monthName(_selectedMonth.month)} ${_selectedMonth.year}",
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const Spacer(),
                  TextButton.icon(
                    icon: const Icon(Icons.calendar_today, size: 18),
                    label: const Text("Change"),
                    onPressed: _pickMonth,
                  ),
                ],
              ),
              const SizedBox(height: 18),
              ElevatedButton(
                onPressed: _submit,
                child: Text(widget.budget == null ? "Save" : "Update"),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  String _monthName(int month) {
    const months = [
      "Jan", "Feb", "Mar", "Apr", "May", "Jun",
      "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"
    ];
    return months[month - 1];
  }
}