import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../../models/listing.dart';
import '../../../bloc/users/create_listing_bloc.dart';

class CreateListingScreen extends StatelessWidget {
  final Listing? listing;

  const CreateListingScreen({super.key, this.listing});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CreateListingBloc(),
      child: _CreateListingView(listing: listing),
    );
  }
}

class _CreateListingView extends StatefulWidget {
  final Listing? listing;

  const _CreateListingView({this.listing});

  @override
  State<_CreateListingView> createState() => _CreateListingViewState();
}

class _CreateListingViewState extends State<_CreateListingView> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _priceController = TextEditingController();
  String _selectedCategory = 'Books';
  String _selectedCondition = 'New';
  final List<XFile> _selectedImages = [];
  final ImagePicker _picker = ImagePicker();

  final List<String> _categories = ['Books', 'Electronics', 'Clothing', 'Others'];

  @override
  void initState() {
    super.initState();
    if (widget.listing != null) {
      _titleController.text = widget.listing!.title;
      _descController.text = widget.listing!.description;
      _priceController.text = widget.listing!.price.toString();
      _selectedCategory = widget.listing!.category.isNotEmpty ? widget.listing!.category : 'Books';
      _selectedCondition = widget.listing!.condition.isNotEmpty ? widget.listing!.condition : 'New';
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    if (_selectedImages.length >= 3) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Maximum of 3 photos allowed.')));
      return;
    }
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 40,
        maxWidth: 1080,
      );
      if (image != null) {
        setState(() {
          _selectedImages.add(image);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error picking image: $e')));
      }
    }
  }

  void _saveListing() {
    final title = _titleController.text.trim();
    final desc = _descController.text.trim();
    final priceStr = _priceController.text.trim();

    if (title.isEmpty || desc.isEmpty || priceStr.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill all fields')));
      return;
    }

    final price = double.tryParse(priceStr);
    if (price == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Invalid price')));
      return;
    }

    context.read<CreateListingBloc>().add(
      CreateListingSubmitted(
        existingListing: widget.listing,
        title: title,
        description: desc,
        price: price,
        category: _selectedCategory,
        condition: _selectedCondition,
        images: _selectedImages,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CreateListingBloc, CreateListingState>(
      listener: (context, state) {
        if (state is CreateListingSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
          Navigator.pop(context);
        } else if (state is CreateListingFailure) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: ${state.error}')));
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(widget.listing == null ? 'Create Listing' : 'Edit Listing', style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18)),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Photos (placeholder UI)
              RichText(
                text: const TextSpan(
                  text: 'Photos ',
                  style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16),
                  children: [TextSpan(text: '*', style: TextStyle(color: Color(0xFFB11A23)))],
                ),
              ),
              const SizedBox(height: 12),
                SizedBox(
                height: 100,
                child: Row(
                  children: [
                    if (_selectedImages.length < 3)
                      GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          height: 100,
                          width: 100,
                          margin: const EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300, style: BorderStyle.solid),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.camera_alt_outlined, color: Colors.grey.shade500),
                              const SizedBox(height: 4),
                              Text('Add Photo', style: TextStyle(color: Colors.grey.shade500, fontSize: 10)),
                            ],
                          ),
                        ),
                      ),
                    Expanded(
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _selectedImages.length,
                        itemBuilder: (context, index) {
                          final file = _selectedImages[index];
                          return Container(
                            height: 100,
                            width: 100,
                            margin: const EdgeInsets.only(right: 8),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: kIsWeb
                                      ? Image.network(file.path, fit: BoxFit.cover)
                                      : Image.file(File(file.path), fit: BoxFit.cover),
                                ),
                                Positioned(
                                  top: 4,
                                  right: 4,
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _selectedImages.removeAt(index);
                                      });
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: const BoxDecoration(
                                        color: Colors.black54,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(Icons.close, color: Colors.white, size: 16),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text('${_selectedImages.length}/3 photos • First photo will be the cover', style: TextStyle(color: Colors.grey.shade500, fontSize: 10)),
              
              const SizedBox(height: 24),
              
              // Item Details
              const Text('Item Details', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 16),
              
              // Title
              RichText(
                text: const TextSpan(
                  text: 'Title ',
                  style: TextStyle(color: Colors.black, fontSize: 14),
                  children: [TextSpan(text: '*', style: TextStyle(color: Color(0xFFB11A23)))],
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _titleController,
                decoration: InputDecoration(
                  hintText: 'e.g. Engineering Math Textbook',
                  hintStyle: TextStyle(color: Colors.grey.shade400),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade200)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade200)),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Category
              RichText(
                text: const TextSpan(
                  text: 'Category ',
                  style: TextStyle(color: Colors.black, fontSize: 14),
                  children: [TextSpan(text: '*', style: TextStyle(color: Color(0xFFB11A23)))],
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _categories.contains(_selectedCategory) ? _selectedCategory : _categories.first,
                    isExpanded: true,
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setState(() {
                          _selectedCategory = newValue;
                        });
                      }
                    },
                    items: _categories.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Condition
              RichText(
                text: const TextSpan(
                  text: 'Condition ',
                  style: TextStyle(color: Colors.black, fontSize: 14),
                  children: [TextSpan(text: '*', style: TextStyle(color: Color(0xFFB11A23)))],
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(child: _buildConditionBtn('New')),
                  const SizedBox(width: 8),
                  Expanded(child: _buildConditionBtn('Like New')),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(child: _buildConditionBtn('Good')),
                  const SizedBox(width: 8),
                  Expanded(child: _buildConditionBtn('Fair')),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Description
              RichText(
                text: const TextSpan(
                  text: 'Description ',
                  style: TextStyle(color: Colors.black, fontSize: 14),
                  children: [TextSpan(text: '*', style: TextStyle(color: Color(0xFFB11A23)))],
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _descController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Describe your item...',
                  hintStyle: TextStyle(color: Colors.grey.shade400),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade200)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade200)),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Pricing
              const Text('Pricing', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 16),
              
              RichText(
                text: const TextSpan(
                  text: 'Price ',
                  style: TextStyle(color: Colors.black, fontSize: 14),
                  children: [TextSpan(text: '*', style: TextStyle(color: Color(0xFFB11A23)))],
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _priceController,
                decoration: InputDecoration(
                  prefixText: '₱  ',
                  hintText: '0',
                  hintStyle: TextStyle(color: Colors.grey.shade400),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade200)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade200)),
                ),
                keyboardType: TextInputType.number,
              ),
              
              const SizedBox(height: 32),
              
              SizedBox(
                width: double.infinity,
                child: BlocBuilder<CreateListingBloc, CreateListingState>(
                  builder: (context, state) {
                    final isLoading = state is CreateListingLoading;
                    return ElevatedButton(
                      onPressed: isLoading ? null : _saveListing,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFB11A23),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        elevation: 0,
                      ),
                      child: isLoading 
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : Text(widget.listing == null ? 'Post Listing' : 'Save Changes', style: const TextStyle(color: Colors.white)),
                    );
                  },
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildConditionBtn(String label) {
    final isSelected = _selectedCondition == label;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedCondition = label;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFB11A23) : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: isSelected ? const Color(0xFFB11A23) : Colors.grey.shade300),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
