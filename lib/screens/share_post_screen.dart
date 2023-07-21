import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:infinite/controllers/forum_controller.dart';

class SharePostScreen extends ConsumerStatefulWidget {
  const SharePostScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _SharePostScreenState();
}

class _SharePostScreenState extends ConsumerState<SharePostScreen> {
  final _formKey = GlobalKey<FormState>();
  final titleController = TextEditingController();
  final bodyController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Share Post'),
      ),
      body: Center(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                controller: titleController,
                decoration: const InputDecoration(
                  hintText: 'Title',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: bodyController,
                decoration: const InputDecoration(
                  hintText: 'Body',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a body';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    ref
                        .read(forumControllerProvider)
                        .createPost(title: titleController.text, body: bodyController.text, context: context);
                  }
                },
                child: const Text("Create"),
              )
            ],
          ),
        ),
      ),
    );
  }
}
