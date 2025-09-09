// flutter_ecommerce_mini_main.dart
// Minimal E-Commerce (Mini) App – Modern UI with unique IDs & proper cart counts.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

// -------------------- Models --------------------

class Product {
  final String id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;

  Product({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.imageUrl,
  });
}

class CartItem {
  final Product product;
  int qty;

  CartItem({required this.product, this.qty = 1});
}

// -------------------- State (Provider) --------------------

class CartModel extends ChangeNotifier {
  final Map<String, CartItem> _items = {};

  List<CartItem> get items => _items.values.toList();

  int get totalItems => _items.values.fold(0, (s, i) => s + i.qty);

  double get totalPrice =>
      _items.values.fold(0, (s, i) => s + i.product.price * i.qty);

  void add(Product p) {
    if (_items.containsKey(p.id)) {
      _items[p.id]!.qty += 1;
    } else {
      _items[p.id] = CartItem(product: p);
    }
    notifyListeners();
  }

  void removeSingle(Product p) {
    if (!_items.containsKey(p.id)) return;
    if (_items[p.id]!.qty > 1) {
      _items[p.id]!.qty -= 1;
    } else {
      _items.remove(p.id);
    }
    notifyListeners();
  }

  void removeAll(Product p) {
    if (_items.containsKey(p.id)) {
      _items.remove(p.id);
      notifyListeners();
    }
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }

  int qtyOf(Product p) => _items[p.id]?.qty ?? 0;
}

// -------------------- Sample Data --------------------

final List<Product> demoProducts = List.generate(
  8,
  (i) => Product(
    id: 'p$i',
    title: 'Product $i',
    description:
        'This is a nice product number $i. Great quality, compact, and value for money.',
    price: 49.99 + i * 10,
    imageUrl: 'https://picsum.photos/seed/p$i/400/300',
  ),
);

// -------------------- App --------------------

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CartModel(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Mini E-Commerce',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
          useMaterial3: true,
        ),
        home: const MainScaffold(),
      ),
    );
  }
}

// -------------------- Navigation Shell --------------------

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _selected = 0;

  final List<Widget> _tabs = [const ProductListPage(), const CartPage()];

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartModel>();

    return Scaffold(
      body: Navigator(
        onGenerateRoute: (settings) {
          return MaterialPageRoute(builder: (context) => _tabs[_selected]);
        },
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selected,
        onDestinationSelected: (i) => setState(() => _selected = i),
        destinations: [
          const NavigationDestination(
              icon: Icon(Icons.storefront), label: 'Shop'),
          NavigationDestination(
            icon: Stack(children: [
              const Icon(Icons.shopping_cart),
              if (cart.totalItems > 0)
                Positioned(
                  right: 0,
                  child: CircleAvatar(
                    radius: 8,
                    backgroundColor: Colors.red,
                    child: Text(
                      cart.totalItems.toString(),
                      style: const TextStyle(fontSize: 10, color: Colors.white),
                    ),
                  ),
                )
            ]),
            label: 'Cart',
          ),
        ],
      ),
    );
  }
}

// -------------------- Pages --------------------

class ProductListPage extends StatelessWidget {
  const ProductListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mini Shop')),
      body: GridView.builder(
        padding: const EdgeInsets.all(12),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.7,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: demoProducts.length,
        itemBuilder: (context, idx) => ProductCard(product: demoProducts[idx]),
      ),
    );
  }
}

class ProductCard extends StatelessWidget {
  final Product product;
  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartModel>();
    final qty = cart.qtyOf(product);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
              child: Image.network(
                product.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: Colors.grey[300],
                  child: const Icon(Icons.broken_image, size: 48),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product.title,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16)),
                Text('₹${product.price.toStringAsFixed(2)}',
                    style: const TextStyle(color: Colors.teal, fontSize: 14)),
                const SizedBox(height: 6),
                qty == 0
                    ? ElevatedButton.icon(
                        onPressed: () => context.read<CartModel>().add(product),
                        icon: const Icon(Icons.add_shopping_cart),
                        label: const Text('Add'),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline),
                            onPressed: () =>
                                context.read<CartModel>().removeSingle(product),
                          ),
                          Text('$qty', style: const TextStyle(fontSize: 16)),
                          IconButton(
                            icon: const Icon(Icons.add_circle_outline),
                            onPressed: () =>
                                context.read<CartModel>().add(product),
                          ),
                        ],
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// -------------------- Cart Page --------------------

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartModel>();

    return Scaffold(
      appBar: AppBar(title: const Text('Your Cart')),
      body: cart.items.isEmpty
          ? const Center(child: Text('Your cart is empty'))
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: cart.items.length,
                    itemBuilder: (context, idx) {
                      final ci = cart.items[idx];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: ListTile(
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(ci.product.imageUrl,
                                width: 56, height: 56, fit: BoxFit.cover),
                          ),
                          title: Text(ci.product.title),
                          subtitle: Text(
                              '₹${ci.product.price.toStringAsFixed(2)} x ${ci.qty}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove_circle_outline),
                                onPressed: () => context
                                    .read<CartModel>()
                                    .removeSingle(ci.product),
                              ),
                              Text(ci.qty.toString()),
                              IconButton(
                                icon: const Icon(Icons.add_circle_outline),
                                onPressed: () =>
                                    context.read<CartModel>().add(ci.product),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text('Total: ₹${cart.totalPrice.toStringAsFixed(2)}',
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () => Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => CheckoutPage())),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Text('Proceed to Checkout'),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () => context.read<CartModel>().clear(),
                        child: const Text('Clear Cart'),
                      )
                    ],
                  ),
                )
              ],
            ),
    );
  }
}

// -------------------- Checkout --------------------

class CheckoutPage extends StatefulWidget {
  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final _formKey = GlobalKey<FormState>();
  String name = '';
  String address = '';
  String phone = '';
  bool isPlacing = false;

  Future<void> _placeOrder() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    setState(() => isPlacing = true);
    await Future.delayed(const Duration(seconds: 2));

    final cart = context.read<CartModel>();
    final total = cart.totalPrice;
    cart.clear();

    setState(() => isPlacing = false);

    if (!mounted) return;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('🎉 Order Confirmed!'),
        content: Text(
            'Thanks, $name! Your order of ₹${total.toStringAsFixed(2)} has been placed.'),
        actions: [
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            child: const Text('OK'),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartModel>();

    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: cart.items.isEmpty
            ? const Center(child: Text('Your cart is empty.'))
            : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          TextFormField(
                            decoration:
                                const InputDecoration(labelText: 'Full name'),
                            validator: (v) => v!.isEmpty ? 'Enter name' : null,
                            onSaved: (v) => name = v!,
                          ),
                          TextFormField(
                            decoration:
                                const InputDecoration(labelText: 'Phone'),
                            keyboardType: TextInputType.phone,
                            validator: (v) => v!.isEmpty ? 'Enter phone' : null,
                            onSaved: (v) => phone = v!,
                          ),
                          TextFormField(
                            decoration:
                                const InputDecoration(labelText: 'Address'),
                            minLines: 2,
                            maxLines: 4,
                            validator: (v) =>
                                v!.isEmpty ? 'Enter address' : null,
                            onSaved: (v) => address = v!,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text('Order summary',
                        style: Theme.of(context).textTheme.titleMedium),
                    ...cart.items.map((ci) => ListTile(
                          title: Text(ci.product.title),
                          subtitle: Text(
                              '${ci.qty} × ₹${ci.product.price.toStringAsFixed(2)}'),
                          trailing: Text(
                              '₹${(ci.qty * ci.product.price).toStringAsFixed(2)}'),
                        )),
                    const SizedBox(height: 8),
                    Text('Total: ₹${cart.totalPrice.toStringAsFixed(2)}',
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    isPlacing
                        ? const Center(child: CircularProgressIndicator())
                        : FilledButton(
                            onPressed: _placeOrder,
                            child: const Padding(
                              padding: EdgeInsets.symmetric(vertical: 12),
                              child: Text('Place Order'),
                            ),
                          )
                  ],
                ),
              ),
      ),
    );
  }
}
