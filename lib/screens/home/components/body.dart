import 'package:flutter/material.dart';

import '../../../models/expense.dart';
import '../../add/add_expense_screen.dart';
import '../../constants.dart';


class Body extends StatelessWidget{
  final List<Expense> expenses; //lista para almacenar los gastos recibidos por los parametros
  final void Function(int) deleteFunt; //capturando la fucnion para posteriormente llamarla y eliminar un gasto
  final void Function() cargarExpenses; //capturando la fucnion para posteriormente llamarla y listar los gastos
  const Body({
    Key? key,
    //definiendo como requeridos los parametros
    required this.expenses,
    required this.deleteFunt,
    required this.cargarExpenses
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: <Widget>[

          /*Parte superior donde se muestra el logo y detalle sobre el total de gastos*/
          Container(
            margin: EdgeInsets.all(20),
            padding: EdgeInsets.symmetric(
              horizontal: 5,
              vertical: 25, // 5 top and bottom
            ),

            child: Row(
              children: [
                //Logo
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 10,
                        offset: Offset(0, 5), // Sombra hacia abajo
                      ),
                    ],
                  ),
                  child:  Image.asset(
                    'assets/images/home_logo.png',
                    width: 120,
                    height: 120,
                    fit: BoxFit.contain,
                  ),

                ),

                //Detalle sobre el total de los gastos
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        'Total de gastos',
                        style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold, color: whiteColor),
                      ),
                      SizedBox(height: 6),
                      Text(
                        '\$${_calculateTotal().toStringAsFixed(2)}',
                        style: TextStyle(fontSize: 26, fontWeight: FontWeight.w600, color: whiteColor),
                      ),
                    ],
                  ),
                ),

              ],

            ),
          ),
          SizedBox(height: 10),


          /*Fondo blanco de la lista*/
          Expanded(child: Stack(
            children: <Widget>[
              Container(
                decoration: BoxDecoration(
                  color: whiteColor,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(45),
                    topRight: Radius.circular(45),
                  ),
                ),
              ),
              Container(
                alignment: Alignment.topCenter,
                padding: EdgeInsets.only(top: 25),
                margin: EdgeInsets.only(top:5),
                child: RichText(
                  text: TextSpan(
                    text: "Transacciones",
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(fontWeight: FontWeight.bold, fontSize: 23),
                  ),
                ),
              ),

              /*Lista con informacion de los gastos*/
              Container(
                padding: EdgeInsets.only(top: 25, bottom: 10),
                margin: EdgeInsets.only(top: 50),
                child: expenses.isEmpty
                    ? Center(child: Text('No hay gastos registrados'))
                    :ListView.builder(
                    itemCount: expenses.length + 1,
                    itemBuilder: (context, index){
                      if (index == expenses.length) {
                        // Último elemento: espacio extra
                        return SizedBox(height: 60); // Ajusta la altura a lo que necesites
                      }
                      final exp = expenses[index];

                      //Creando la card con la informacion del gasto
                      return Card(
                        margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Parte izquierda de la card: descripción, categoria y fecha
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      exp.description,
                                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                                    ),
                                    SizedBox(height: 6),
                                    Text(
                                      'Categoria: ${exp.category}',
                                      style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                                    ),
                                    SizedBox(height: 6),
                                    Text(
                                      'Fecha: ${exp.date}',
                                      style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                                    ),
                                  ],
                                ),
                              ),

                              // Parte derecha de la card: monto y PopupMenuButton
                              Text(
                                '\$ ${exp.amount.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: blackColor,
                                ),
                              ),
                              PopupMenuButton<String>(
                                onSelected: (value) async{
                                  if (value == 'editar') {
                                    //opcion para editar un gasto y llamada a la funcion encargada
                                    await _editarGasto(context, exp);
                                  } else if (value == 'eliminar') {
                                    //opcion para eliminar un gasto y llamada a la funcion encargada
                                    _confirmDelete(exp.id!, context);
                                  }
                                },
                                //Asignando el valor seleccionado en el PopupMenu
                                itemBuilder: (context) => [
                                  PopupMenuItem(value: 'editar', child: Text('Editar')),
                                  PopupMenuItem(value: 'eliminar', child: Text('Eliminar')),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                ),
              ),

            ],
          ),
          ),
        ],
      ),
    );
  }

  //Funcion que se encarga de iterar la lista de gastos y retorna la sumatoria de todos los montos de los gastos
  double _calculateTotal() {
    return expenses.fold(0.0, (sum, item) => sum + item.amount);
  }

  //funcion que recibe como parametros el contexto y el gasto a ser editado en sus valores
  //luego realiza la llamada de la pantalla que contiene el formulario y le pasa como parametro el objeto gasto
  Future<void> _editarGasto(BuildContext context, Expense exp, ) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) =>
            AddExpenseScreen(expense: exp),//llamada de la pantalla que contiene el formulario
      ),
    );
    cargarExpenses();//una vez completada la opercion anterior llama al metodo para cargar la lista de gastos
  }


  /*funcion encargada de mostrar un cuadro de dialogo y que el usuario podra confirmar o descartar
  la eliminacion de un gasto, recibe como parametros el identificador del gasto y el contexto*/
  void _confirmDelete(int id, BuildContext context) {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
        title: Text('¿Eliminar gasto?'),
        content: Text('Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              deleteFunt(id); //llamada a la funcion que se encarga de completar la eliminacion
            },
            child: Text('Eliminar'),
          ),
        ],
      ),
    );
  }

}




