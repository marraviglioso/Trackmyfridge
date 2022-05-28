import 'package:objectbox/objectbox.dart';

@Entity()
class Product {
  int id = 0;
  String name;
  DateTime selectedDate;

  Product({
    required this.name,
    required this.selectedDate,
  });
}
