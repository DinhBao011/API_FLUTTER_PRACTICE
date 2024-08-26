import 'package:app_api/app/model/category.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:app_api/app/data/api.dart';
import 'package:app_api/app/data/sqlite.dart';
import 'package:app_api/app/model/cart.dart';
import 'package:app_api/app/model/product.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Page3 extends StatefulWidget {
  const Page3({
    Key? key,
  }) : super(key: key);

  @override
  State<Page3> createState() => _Page3State();
}

class _Page3State extends State<Page3> {
  final DatabaseHelper _databaseService = DatabaseHelper();
  List<CategoryModel> _categories = [];
  List<ProductModel> _products = [];
  int _selectedCategoryId = -1;

  @override
  void initState() {
    super.initState();
    _getCategories();
    _getProducts();
  }

  Future<void> _getCategories() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _categories = await APIRepository().getCategory(
        prefs.getString('accountID').toString(),
        prefs.getString('token').toString());
    setState(() {});
  }

  Future<void> _getProducts() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _products = await APIRepository().getProduct(
        prefs.getString('accountID').toString(),
        prefs.getString('token').toString());
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Column(
        children: [
          Text("Main page"),
          Expanded(
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: DropdownButton<int>(
                        value: _selectedCategoryId,
                        hint: const Text('Select category'),
                        onChanged: (int? value) {
                          setState(() {
                            _selectedCategoryId = value ?? -1;
                          });
                        },
                        items: [
                          const DropdownMenuItem<int>(
                            value: -1,
                            child: Text('All'),
                          ),
                          ...List.generate(
                            _categories.length,
                            (index) => DropdownMenuItem<int>(
                              value: _categories[index].id,
                              child: Text(_categories[index].name),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Expanded(
                  child: _selectedCategoryId == -1
                      ? ListView.separated(
                          itemCount: _products.length,
                          separatorBuilder: (context, index) => const Divider(),
                          itemBuilder: (context, index) {
                            final product = _products[index];
                            return _buildProduct(product, context);
                          },
                        )
                      : ListView.separated(
                          itemCount: _products
                              .where((p) => p.categoryId == _selectedCategoryId)
                              .length,
                          separatorBuilder: (context, index) => const Divider(),
                          itemBuilder: (context, index) {
                            final product = _products
                                .where(
                                    (p) => p.categoryId == _selectedCategoryId)
                                .toList()[index];
                            return _buildProduct(product, context);
                          },
                        ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildProduct(ProductModel product, BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Container(
              height: 80,
              width: 80,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(product.imageUrl),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4.0),
                  Text('Category: ${product.categoryId}'),
                  const SizedBox(height: 4.0),
                  Text('Price: ${product.price}'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
