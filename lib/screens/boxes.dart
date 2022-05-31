import 'package:elegant_notification/elegant_notification.dart';
import 'package:elegant_notification/resources/arrays.dart';
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
      body: Padding(
        padding: const EdgeInsets.only(top: 18.0),
        child: _groups.isEmpty
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: const [
                  SizedBox(
                    height: 280,
                    child: Image(
                      image: AssetImage('assets/fridge.png'),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 38.0),
                    child: Center(
                      child: Text(
                        'There are no products.',
                        style: TextStyle(fontSize: 25),
                      ),
                    ),
                  ),
                ],
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
                        ElegantNotification(
                          enableShadow: false,
                          showProgressIndicator: false,
                          radius: 25,
                          notificationPosition: NOTIFICATION_POSITION.bottom,
                          toastDuration: const Duration(milliseconds: 4500),
                          title: const Text('Deleted!'),
                          description:
                              Text(product.name + " has been deleted."),
                          icon: const Icon(
                            Icons.delete_forever_rounded,
                            color: Colors.red,
                          ),
                          progressIndicatorColor: Colors.red,
                        ).show(context);
                      });
                    },
                    product: product,
                  );
                },
              ),
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

    int daysBetween(DateTime from, DateTime to) {
      from = DateTime(from.year, from.month, from.day);
      to = DateTime(to.year, to.month, to.day);
      return (to.difference(from).inHours / 24).round();
    }

    final today = DateTime.now();
    final difference = daysBetween(today, endDate);

    return Padding(
      padding: const EdgeInsets.all(6.0),
      child: InkWell(
        onLongPress: onPressed,
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: difference <= 0
                  ? const Color.fromARGB(255, 209, 171, 168)
                  : const Color.fromARGB(255, 129, 167, 130),
            ),
            color: difference <= 0
                ? const Color.fromARGB(255, 235, 207, 228)
                : const Color.fromARGB(255, 200, 233, 220),
            borderRadius: const BorderRadius.all(Radius.circular(15)),
          ),
          child: Container(
            margin: const EdgeInsets.only(left: 10, right: 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.center,
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
                  child: Text(
                    'Giorni rimanenti: ' + difference.toString(),
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
