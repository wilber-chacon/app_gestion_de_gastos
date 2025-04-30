class Expense {
  //Propiedades del objeto
  int? id;
  String description;
  String category;
  double amount;
  String date;

//Constructor
  Expense({
    this.id,
    required this.description,
    required this.category,
    required this.amount,
    required this.date,
  });

  //Convierte el objeto en un mapa para SQLite
  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      'description': description,
      'category': category,
      'amount': amount,
      'date': date,
    };

    if (id != null) {
      map['id'] = id; //Solo incluye ID si no es null
    }
    return map;
  }

  //Crea objeto desde un mapa
  factory Expense.fromMap(Map<String, dynamic> map) {
    return Expense(
      id: map['id'],
      description:  map['description'],
      category: map['category'],
      amount: map['amount'],
      date: map['date'],
    );
  }
}
