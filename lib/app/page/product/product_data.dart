// ignore_for_file: depend_on_referenced_packages

import 'dart:io';
import 'package:app_api/app/data/api.dart';
import 'package:app_api/app/model/product.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'product_add.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProductBuilder extends StatefulWidget {
  const ProductBuilder({
    Key? key,
  }) : super(key: key);

  @override
  State<ProductBuilder> createState() => _ProductBuilderState();
}

class _ProductBuilderState extends State<ProductBuilder> {
  Future<List<ProductModel>> _getProducts() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return await APIRepository().getProduct(
        prefs.getString('accountID').toString(),
        prefs.getString('token').toString());
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<ProductModel>>(
      future: _getProducts(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
            child: Text('No products available'),
          );
        }
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final itemProduct = snapshot.data![index];
              return _buildProduct(itemProduct, context);
            },
          ),
        );
      },
    );
  }

  Widget _buildProduct(ProductModel product, BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: product.imageUrl != null
                  ? (product.imageUrl!.startsWith('http')
                      ? Image.network(
                          product.imageUrl!,
                          height: 100,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.image),
                        )
                      : Image.file(
                          File(product.imageUrl!),
                          height: 100,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.image),
                        ))
                  : const Icon(Icons.image),
            ),
            const SizedBox(width: 20.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name ?? '',
                    style: const TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4.0),
                  Text('Price: \$${product.price ?? 0}'),
                  const SizedBox(height: 4.0),
                  Text(product.description ?? ''),
                ],
              ),
            ),
            IconButton(
                onPressed: () async {
                  SharedPreferences pref =
                      await SharedPreferences.getInstance();
                  setState(() async {
                    await APIRepository().removeProduct(
                        product.id,
                        pref.getString('accountID').toString(),
                        pref.getString('token').toString());
                  });
                },
                icon: const Icon(
                  Icons.delete,
                  color: Colors.red,
                )),
            IconButton(
              onPressed: () {
                Navigator.of(context)
                    .push(
                      MaterialPageRoute(
                        builder: (_) => ProductAdd(
                          isUpdate: true,
                          productModel: product,
                        ),
                        fullscreenDialog: true,
                      ),
                    )
                    .then((_) => setState(() {}));
              },
              icon: Icon(
                Icons.edit,
                color: Colors.yellow.shade800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
