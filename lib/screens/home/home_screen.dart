import 'package:flutter/material.dart';
import '../add/add_expense_screen.dart';
import '../../db/database_helper.dart';
import '../../models/expense.dart';
import '../constants.dart';
import 'components/body.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
    List<Expense> _expenses = [];

  @override
  void initState() {
    super.initState();
    _loadExpenses();
  }

  Future<void> _loadExpenses() async {
    final expenses = await DatabaseHelper().getExpenses();
    setState(() {
      _expenses = expenses;
    });
  }


  Future<void> _deleteExpense(int id) async {
    await DatabaseHelper().deleteExpense(id);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Gasto eliminado exitosamente', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.green,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(10),
      ),
    );
    _loadExpenses(); //Actualiza la lista de gastos
  }

  @override
  Widget build(BuildContext context) {

    /*Widget principal*/
    return Scaffold(
      backgroundColor: whiteColor,

      //Cuerpo de la pagina de inicio
      body: Body(
        expenses: _expenses,
        deleteFunt: _deleteExpense,
        cargarExpenses: _loadExpenses,
      ),

      //Boton flotante para ir a pagina de agregar o modificar un gasto
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddExpenseScreen()),
          );
          _loadExpenses(); //Recarga la lista al volver
        },
        tooltip: 'Agregar gasto',
        child: Icon(Icons.add),
      ),
    );

  }

}


