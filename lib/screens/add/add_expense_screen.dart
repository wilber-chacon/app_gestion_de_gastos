import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; //Paquete para formatear fechas
import '../../db/database_helper.dart';
import '../../models/expense.dart';
import '../constants.dart';


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

  //Metodo para seleccionar fecha
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
      backgroundColor: whiteColor,
      extendBodyBehindAppBar: true, // Extiende el body detrás del AppBar
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              iconTheme: const IconThemeData(
                  color: Colors.white,
                  size: 27.0
              ),
            ),
          ),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Definir si estamos en una pantalla ancha (tablet/escritorio)
          bool isWideScreen = constraints.maxWidth >= 600;

          return SingleChildScrollView(

            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 800),
                child:
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [

                    //Parte superior de la pantalla
                    Container(
                      decoration: BoxDecoration(
                        color: MainColor,
                      ),
                      child:
                      Column(
                        children: [
                          Container(
                            padding: EdgeInsets.only(top: 75, left: 55, right: 5, bottom: 25),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: <Widget>[
                                Text(
                                  isEditing ? 'Editar gasto' : 'Agregar gasto',
                                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: whiteColor),
                                ),
                                Icon(
                                  Icons.edit_note,
                                  size: 90,
                                  color: Colors.white,
                                ),

                              ],
                            ),
                          ),
                          Container(
                            alignment: Alignment.topCenter,
                            padding: EdgeInsets.only(top: 25, left: 15, right: 15, bottom: 25),
                            margin: EdgeInsets.only(top: 5),
                            decoration: BoxDecoration(
                              color: whiteColor,
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(45),
                                topRight: Radius.circular(45),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),


                    //Formulario para registrar o actualizar un gasto
                    Form(
                      key: _formKey,
                      child: Container(
                        padding: EdgeInsets.only(top: 0, left: 25, right: 25, bottom: 50),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            isWideScreen ? Column(
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        //Campo para descripción para tablet o superior
                                        child: _buildTextFieldDescripcion(),
                                      ),
                                      SizedBox(width: 16),
                                      Expanded(
                                        //Campo para monto para tablet o superior
                                          child: _buildTextFieldMonto(),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Expanded(
                                        //Campo para descripción para tablet o superior
                                        child: _buildTextFieldCategoria(),
                                      ),
                                      SizedBox(width: 16),
                                      Expanded(
                                        //Campo para monto para tablet o superior
                                        child: _buildTextFieldFecha(),
                                      ),
                                    ],
                                  )

                                ]
                            ): Column(
                              //Campos para version celular
                              children: [
                                _buildTextFieldDescripcion(),
                                _buildTextFieldMonto(),
                                _buildTextFieldCategoria(),
                                _buildTextFieldFecha(),
                              ],
                            ),

                            //Boton para enviar el formulario
                            Container(
                              margin: EdgeInsets.only(bottom: 0, top: 50),
                              padding: EdgeInsets.only(left: 35, right: 35),
                              child: ElevatedButton(
                                onPressed: _submitExpense,
                                child: Text('Guardar', style: TextStyle(fontSize: 15)),
                                style: ElevatedButton.styleFrom(
                                  shape: const StadiumBorder(),
                                  elevation: 7,
                                  shadowColor: Colors.black,
                                  minimumSize: const Size.fromHeight(60),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ]
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  //Metodo encargado de crear el widget utilizado para el campo descripcion
  Widget _buildTextFieldDescripcion() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0.5),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            offset: Offset(-2, 2),
            blurRadius: 3,
          ),
          BoxShadow(
            color: Colors.white,
            offset: Offset(-1, -1),
            blurRadius: 6,
          ),
        ],
      ),
      child: TextFormField(
        controller: _descriptionController,
        decoration: const InputDecoration(
          labelText: 'Descripción',
          labelStyle: TextStyle(
            fontSize: 14,
            color: Colors.black54,
          ),
          border: InputBorder.none,
        ),
        style: const TextStyle(color: Colors.black, fontSize: 14),
        autovalidateMode: AutovalidateMode.onUserInteraction,
        validator:
            (value) =>
        value!.isEmpty ? 'Ingrese una descripción' : null,
      ),
    );
  }

  //Metodo encargado de crear el widget utilizado para el campo monto
  Widget _buildTextFieldMonto() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0.5),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            offset: Offset(-2, 2),
            blurRadius: 3,
          ),
          BoxShadow(
            color: Colors.white,
            offset: Offset(-1, -1),
            blurRadius: 6,
          ),
        ],
      ),
      child: TextFormField(
        controller: _amountController,
        decoration: const InputDecoration(
          hintText: '\$0.0',
          labelText: 'Monto',
          labelStyle: TextStyle(
            fontSize: 14,
            color: Colors.black54,
          ),
          border: InputBorder.none,
        ),
        keyboardType: TextInputType.numberWithOptions(decimal: true),
        style: const TextStyle(color: Colors.black, fontSize: 14),
        autovalidateMode: AutovalidateMode.onUserInteraction,
        validator:
            (value) =>
        value!.isEmpty || double.tryParse(value) == null || double.tryParse(value) == 0.0
            ? 'Ingrese un monto válido y superior a cero'
            : null,
      ),
    );
  }

  //Metodo encargado de crear el widget utilizado para el campo categoria
  Widget _buildTextFieldCategoria() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0.5),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            offset: Offset(-2, 2),
            blurRadius: 3,
          ),
          BoxShadow(
            color: Colors.white,
            offset: Offset(-1, -1),
            blurRadius: 6,
          ),
        ],
      ),
      child: DropdownButtonFormField<String>(
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
        decoration: InputDecoration(
          labelText: 'Categoría',
          labelStyle: TextStyle(
            fontSize: 14,
            color: Colors.black54,
          ),
          border: InputBorder.none,
        ),
        style: const TextStyle(color: Colors.black, fontSize: 14),
      ),
    );
  }

  //Metodo encargado de crear el widget utilizado para el campo fecha
  Widget _buildTextFieldFecha() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            offset: Offset(-2, 2),
            blurRadius: 3,
          ),
          BoxShadow(
            color: Colors.white,
            offset: Offset(-1, -1),
            blurRadius: 6,
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Fecha: ${DateFormat('yyy-MM-dd').format(_selectedDate)}',
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(8),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  offset: Offset(2.5, 2.5),
                  blurRadius: 3,
                ),
                BoxShadow(
                  color: Colors.white,
                  offset: Offset(-1, -1),
                  blurRadius: 6,
                ),
              ],
            ),
            child: TextButton(
              onPressed: _pickDate,
              child: Icon(Icons.edit_calendar_outlined),
              style: TextButton.styleFrom(
                backgroundColor: Colors.transparent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ),
        ],
      ),
    );
  }


}





