import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:gown_rental/Admin/Forms/addCat.dart';
import 'package:gown_rental/Admin/Forms/colors.dart';
import 'package:gown_rental/Admin/Forms/size.dart';
import 'package:gown_rental/Admin/Forms/style.dart';

class Categories extends StatelessWidget {
  const Categories({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Categories'),
      ),
      body: const CategoryAndColorsPage(),
    );
  }
}

class CategoryAndColorsPage extends StatelessWidget {
  const CategoryAndColorsPage({Key? key}) : super(key: key);

  Stream<List<Map<String, dynamic>>> _categoryStream() {
    return Supabase.instance.client
        .from('category')
        .stream(primaryKey: ['id'])
        .map((data) => List<Map<String, dynamic>>.from(data));
  }

  Stream<List<Map<String, dynamic>>> _colorsStream() {
    return Supabase.instance.client
        .from('colors')
        .stream(primaryKey: ['id'])
        .map((data) => List<Map<String, dynamic>>.from(data));
  }

  Stream<List<Map<String, dynamic>>> _sizeStream() {
    return Supabase.instance.client
        .from('size')
        .stream(primaryKey: ['id'])
        .map((data) => List<Map<String, dynamic>>.from(data));
  }

  Stream<List<Map<String, dynamic>>> _styleStream() {
    return Supabase.instance.client
        .from('gown_style')
        .stream(primaryKey: ['id'])
        .map((data) => List<Map<String, dynamic>>.from(data));
  }

  Future<void> _deleteCategory(dynamic categoryId) async {
    final response = await Supabase.instance.client
        .from('category')
        .delete()
        .eq('id', categoryId.toString());

    if (response.error != null) {
      throw Exception(response.error!.message);
    }
  }

  Future<void> _deleteColors(dynamic colorsId) async {
    final response = await Supabase.instance.client
        .from('colors')
        .delete()
        .eq('id', colorsId.toString());

    if (response.error != null) {
      throw Exception(response.error!.message);
    }
  }

  Future<void> _deleteSize(dynamic sizeId) async {
    final response = await Supabase.instance.client
        .from('size')
        .delete()
        .eq('id', sizeId.toString());

    if (response.error != null) {
      throw Exception(response.error!.message);
    }
  }

  Future<void> _deleteStyle(dynamic styleId) async {
    final response = await Supabase.instance.client
        .from('gown_style')
        .delete()
        .eq('id', styleId.toString());

    if (response.error != null) {
      throw Exception(response.error!.message);
    }
  }

  Widget _buildCategoryList(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.green.withOpacity(0.5),
              spreadRadius: 5,
              blurRadius: 7,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Category List',
                  style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.add, color: Colors.blue),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) => const AddCategoryForm(),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            Expanded(
              child: StreamBuilder<List<Map<String, dynamic>>>(
                stream: _categoryStream(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('No categories found'));
                  }

                  final categories = snapshot.data!;

                  return ListView(
                    children: categories.map((category) {
                      return ListTile(
                        title: Text(category['type']),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () async {
                            try {
                              await _deleteCategory(category['id']);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Category deleted successfully')),
                              );
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Error: $e')),
                              );
                            }
                          },
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSizeList(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.green.withOpacity(0.5),
              spreadRadius: 5,
              blurRadius: 7,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Size List',
                  style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.add, color: Colors.blue),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) => const AddSizeForm(),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            Expanded(
              child: StreamBuilder<List<Map<String, dynamic>>>(
                stream: _sizeStream(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('No sizes found'));
                  }

                  final sizes = snapshot.data!;

                  return ListView(
                    children: sizes.map((size) {
                      return ListTile(
                        title: Text(size['size']),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () async {
                            try {
                              await _deleteSize(size['id']);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Size deleted successfully')),
                              );
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Error: $e')),
                              );
                            }
                          },
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColorsList(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.blue.withOpacity(0.5),
              spreadRadius: 5,
              blurRadius: 7,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Colors List',
                  style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.add, color: Colors.blue),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) => const AddColorForm(),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            Expanded(
              child: StreamBuilder<List<Map<String, dynamic>>>(
                stream: _colorsStream(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('No colors found'));
                  }

                  final colors = snapshot.data!;

                  return ListView(
                    children: colors.map((color) {
                      return ListTile(
                        title: Text(color['colors']),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () async {
                            try {
                              await _deleteColors(color['id']);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Color deleted successfully')),
                              );
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Error: $e')),
                              );
                            }
                          },
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStyleList(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.green.withOpacity(0.5),
              spreadRadius: 5,
              blurRadius: 7,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Style List',
                  style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.add, color: Colors.blue),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) => const AddStyleForm(),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            Expanded(
              child: StreamBuilder<List<Map<String, dynamic>>>(
                stream: _styleStream(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('No style found'));
                  }

                  final styles = snapshot.data!;

                  return ListView(
                    children: styles.map((gown_style) {
                      return ListTile(
                        title: Text(gown_style['style']),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () async {
                            try {
                              await _deleteStyle(gown_style['id']);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Style deleted successfully')),
                              );
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Error: $e')),
                              );
                            }
                          },
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Determine screen size
    final screenWidth = MediaQuery.of(context).size.width;

    // Choose layout based on screen width
    final isPhone = screenWidth < 600;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: isPhone
          ? Column(
              children: [
                _buildCategoryList(context),
                const SizedBox(height: 16.0),
                _buildSizeList(context),
                const SizedBox(height: 16.0),
                _buildColorsList(context),
                  const SizedBox(height: 16.0),
                _buildStyleList(context),
              ],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Flexible(child: _buildCategoryList(context)),
                const SizedBox(width: 16.0),
                Flexible(child: _buildSizeList(context)),
                const SizedBox(width: 16.0),
                Flexible(child: _buildColorsList(context)),
                const SizedBox(width: 16.0),
                Flexible(child: _buildStyleList(context)),
                const SizedBox(width: 16.0),
              ],
            ),
    );
  }
}
