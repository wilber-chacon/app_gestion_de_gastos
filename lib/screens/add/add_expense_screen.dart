import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; //Paquete para formatear fechas
import '../../db/database_helper.dart';
import '../../models/expense.dart';

//Pantalla para agregar/editar gastos
class AddExpenseScreen extends StatefulWidget {
  final Expense? expense; //Si es null = agregar gasto, si no = edición de gasto

  const AddExpenseScreen({super.key, this.expense}); //Constructor que recibe el gasto a editar

  @override
  _AddExpenseScreenState createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  //Controladores para los campos de texto
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _descriptionController;
  late TextEditingController _amountController;
  String _selectedCategory = 'Comida'; //Categoría por defecto
  DateTime _selectedDate = DateTime.now(); //Fecha por defecto

  //Lista de categorías disponibles
  final List<String> _categories = [
    'Comida',
    'Transporte',
    'Entretenimiento',
    'Salud',
    'Educación',
    'Ropa y Zapatos',
    'Impuestos',
    'Vivienda',
    'Otros',
  ];

  @override
  void initState() {
    super.initState();
    //Inicializa los controladores con los valores del gasto si es edición
    _descriptionController = TextEditingController(
      text: widget.expense?.description ?? '',
    );
    _amountController = TextEditingController(
      text: widget.expense != null ? widget.expense!.amount.toString() : '',
    );
    _selectedCategory = widget.expense?.category ?? 'Comida';
    _selectedDate =
    widget.expense != null
        ? DateFormat('yyyy-MM-dd').parse(widget.expense!.date)
        : DateTime.now();
  }

  //Guarda o actualiza el gasto según el caso (edición/creación)
  void _submitExpense() async {
    if (_formKey.currentState!.validate()) {
      final expense = Expense(
        id: widget.expense?.id, //Mantiene el ID si está editando
        description: _descriptionController.text,
        category: _selectedCategory,
        amount: double.parse(_amountController.text),
        date: DateFormat('yyyy-MM-dd').format(_selectedDate),
      );

      //Guarda o actualiza el gasto
      try{
        if(widget.expense == null) {
          await DatabaseHelper().insertExpense(expense);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gasto guardado exitosamente', style: TextStyle(color: Colors.white)),
              backgroundColor: Colors.green,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              duration: Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
              margin: EdgeInsets.all(10),
            ),
          );
        } else {
          await DatabaseHelper().updateExpense(expense);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gasto actualizado exitosamente', style: TextStyle(color: Colors.white)),
              backgroundColor: Colors.green,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              duration: Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
              margin: EdgeInsets.all(10),
            ),
          );
        }

        await Future.delayed(Duration(milliseconds: 1500)); //Espera para que el usuario vea el mensaje

        Navigator.pop(context);
      }catch (e){
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al guardar el gasto: $e'),
            duration: Duration(seconds: 3),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  //Método para seleccionar fecha
  void _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.expense != null; //Determina si está en modo edición
    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? 'Editar gasto' : 'Agregar gasto')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: 'Descripción'),
                validator:
                    (value) =>
                value!.isEmpty ? 'Ingrese una descripción' : null,
              ),
              TextFormField(
                controller: _amountController,
                decoration: InputDecoration(labelText: 'Monto'),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                validator:
                    (value) =>
                value!.isEmpty || double.tryParse(value) == null
                    ? 'Ingrese un monto válido'
                    : null,
              ),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                items:
                _categories.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged:
                    (value) => setState(() => _selectedCategory = value!),
                decoration: InputDecoration(labelText: 'Categoría'),
              ),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Fecha: ${DateFormat('yyy-MM-dd').format(_selectedDate)}',
                    ),
                  ),
                  TextButton(
                    onPressed: _pickDate,
                    child: Text('Cambiar fecha'),
                  ),
                ],
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitExpense,
                child: Text('Guardar Gasto'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
