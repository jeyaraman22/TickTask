import 'package:flutter/material.dart';
import '../../../data/model/comments_response.dart';

class CommentsSection extends StatelessWidget {
  final List<CommentsResponse> comments;
  final Function(String) onDeleteComment;
  final Function(String, String) onUpdateComment;

  const CommentsSection({
    super.key,
    required this.comments,
    required this.onDeleteComment,
    required this.onUpdateComment,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Comments (${comments.length})',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: comments.length,
          separatorBuilder: (_, __) => const Divider(),
          itemBuilder: (context, index) {
            final comment = comments[index];
            return CommentTile(
              comment: comment,
              onDelete: () => onDeleteComment(comment.id ?? ''),
              onUpdate: (content) => onUpdateComment(comment.id ?? '', content),
            );
          },
        ),
      ],
    );
  }
}

class CommentTile extends StatefulWidget {
  final CommentsResponse comment;
  final VoidCallback onDelete;
  final Function(String) onUpdate;

  const CommentTile({
    super.key,
    required this.comment,
    required this.onDelete,
    required this.onUpdate,
  });

  @override
  State<CommentTile> createState() => _CommentTileState();
}

class _CommentTileState extends State<CommentTile> {
  bool _isEditing = false;
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.comment.content);
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: _isEditing
          ? TextField(
              controller: _controller,
              autofocus: true,
              onSubmitted: _handleSubmit,
            )
          : Text(widget.comment.content ?? ''),
      subtitle: Text(
        _formatDate(
            DateTime.tryParse(widget.comment.postedAt ?? '') ?? DateTime.now()),
        style: Theme.of(context).textTheme.bodySmall,
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(_isEditing ? Icons.save : Icons.edit),
            onPressed: _toggleEdit,
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: widget.onDelete,
          ),
        ],
      ),
    );
  }

  void _toggleEdit() {
    if (_isEditing) {
      FocusScope.of(context).requestFocus(FocusNode());
      _handleSubmit(_controller.text);
    } else {
      setState(() => _isEditing = !_isEditing);
    }
  }

  void _handleSubmit(String value) {
    if (value.trim().isNotEmpty) {
      widget.onUpdate(value);
      setState(() => _isEditing = !_isEditing);
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute}';
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
