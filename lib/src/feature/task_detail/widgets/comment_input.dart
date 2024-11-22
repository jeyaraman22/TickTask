import 'package:flutter/material.dart';

class CommentInput extends StatefulWidget {
  final Function(String) onSubmit;

  const CommentInput({
    super.key,
    required this.onSubmit,
  });

  @override
  State<CommentInput> createState() => _CommentInputState();
}

class _CommentInputState extends State<CommentInput> {
  final _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                decoration: const InputDecoration(
                  hintText: 'Add a comment...',
                  border: InputBorder.none,
                ),
                maxLines: null,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.send),
              onPressed: _submitComment,
            ),
          ],
        ),
      ),
    );
  }

  void _submitComment() {
    final comment = _controller.text.trim();
    if (comment.isNotEmpty) {
      widget.onSubmit(comment);
      _controller.clear();
      FocusScope.of(context).requestFocus(FocusNode());
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
