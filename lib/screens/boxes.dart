import 'package:date_count_down/date_count_down.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:trackmyfridge/models/categories.dart';
import 'package:trackmyfridge/objectbox.g.dart';
import 'package:trackmyfridge/screens/add_product.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _groups = <Product>[];
  late final Store _store;
  late final Box<Product> _groupsBox;

  Future<void> _addProduct() async {
    final result = await showDialog(
      context: context,
      builder: (_) => const AddProductScreen(),
    );

    if (result != null && result is Product) {
      _groupsBox.put(result);
      _loadGroups();
    }
  }

  void _loadGroups() {
    _groups.clear();
    setState(() {
      _groups.addAll(_groupsBox.getAll());
    });
  }

  Future<void> _loadStore() async {
    _store = await openStore();
    _groupsBox = _store.box<Product>();
    _loadGroups();
  }

  Future<void> _onDelete(Product product) async {
    _store.box<Product>().remove(product.id);
    _loadGroups();
  }

  @override
  void initState() {
    _loadStore();
    super.initState();
  }

  @override
  void dispose() {
    _store.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE5DBD9), //gainsboro
      appBar: AppBar(
        centerTitle: true,
        toolbarHeight: 70,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(25))),
        shadowColor: const Color(0xFF9AD9DB),
        title: const Text(
          'Track my fridge',
        ),
      ),
      body: _groups.isEmpty
          ? const Center(
              child: Text('There are no products'),
            )
          : GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
              ),
              itemCount: _groups.length,
              itemBuilder: (context, index) {
                final product = _groups[index];
                return _CardProductItem(
                  onPressed: () {
                    setState(() {
                      _onDelete(product);
                    });
                  },
                  product: product,
                );
              },
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.extended(
        label: const Text('Add product'),
        onPressed: _addProduct,
      ),
    );
  }
}

class _CardProductItem extends StatelessWidget {
  const _CardProductItem({
    required this.product,
    required this.onPressed,
    Key? key,
  }) : super(key: key);

  final Product product;

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    DateTime endDate = product.selectedDate;
    String formattedDate = DateFormat('dd-MM-yyyy').format(endDate);

    return Padding(
      padding: const EdgeInsets.all(6.0),
      child: InkWell(
        onLongPress: onPressed,
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFF4CFDF)),
            color: const Color(0xFFEB96AA).withOpacity(0.7),
            borderRadius: const BorderRadius.all(Radius.circular(15)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 14.0),
                child: Text(
                  product.name.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Text.rich(
                TextSpan(
                  text: 'Scadenza: ',
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 10,
                  ),
                  children: <TextSpan>[
                    TextSpan(
                      text: formattedDate,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: CountDownText(
                  showLabel: true,
                  longDateName: true,
                  due: endDate,
                  finishedText: 'Prodotto scaduto!',
                  style: const TextStyle(color: Colors.black),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
