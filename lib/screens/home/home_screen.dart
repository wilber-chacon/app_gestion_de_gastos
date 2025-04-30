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
    _loadExpenses(); //Actualiza la lista de gastos
  }

  @override
  Widget build(BuildContext context) {

    /*Widget principal*/
    return Scaffold(
      backgroundColor: MainColor,

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


