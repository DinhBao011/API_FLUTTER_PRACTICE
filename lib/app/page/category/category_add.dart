import 'package:app_api/app/data/api.dart';
import 'package:app_api/app/model/category.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CategoryAdd extends StatefulWidget {
  final bool isUpdate;
  final CategoryModel? categoryModel;
  const CategoryAdd({super.key, this.isUpdate = false, this.categoryModel});

  @override
  State<CategoryAdd> createState() => _CategoryAddState();
}

class _CategoryAddState extends State<CategoryAdd> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _imageController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  String titleText = "";

  Future<void> _onSave() async {
    final name = _nameController.text;
    final description = _descController.text;
    final image = _imageController.text;
    var pref = await SharedPreferences.getInstance();
    await APIRepository().addCategory(
        CategoryModel(id: 0, name: name, imageUrl: image, desc: description),
        pref.getString('accountID').toString(),
        pref.getString('token').toString());
    setState(() {});
    Navigator.pop(context);
  }

  Future<void> _onUpdate(int id) async {
    final name = _nameController.text;
    final description = _descController.text;
    final image = _imageController.text;
    var pref = await SharedPreferences.getInstance();

    await APIRepository().updateCategory(
        id,
        CategoryModel(
            id: widget.categoryModel!.id,
            name: name,
            imageUrl: image,
            desc: description),
        pref.getString('accountID').toString(),
        pref.getString('token').toString());
    Navigator.pop(context);
  }

  @override
  void initState() {
    super.initState();
    if (widget.categoryModel != null && widget.isUpdate) {
      _nameController.text = widget.categoryModel!.name;
      _descController.text = widget.categoryModel!.desc;
      _imageController.text = widget.categoryModel!.imageUrl;
    }
    titleText = widget.isUpdate ? "Update Category" : "Add New Category";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(titleText),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                elevation: 3,
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      TextField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Enter name',
                        ),
                      ),
                      const SizedBox(height: 16.0),
                      TextField(
                        controller: _imageController,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Enter imageURL',
                        ),
                      ),
                      const SizedBox(height: 16.0),
                      TextField(
                        controller: _descController,
                        maxLines: 7,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Enter description',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16.0),
              SizedBox(
                height: 45.0,
                child: ElevatedButton(
                  onPressed: () {
                    widget.isUpdate
                        ? _onUpdate(widget.categoryModel!.id)
                        : _onSave();
                  },
                  child: const Text(
                    'Save',
                    style: TextStyle(
                      fontSize: 16.0,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
