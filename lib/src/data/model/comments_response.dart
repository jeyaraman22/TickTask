class CommentsResponse {
  String? content;
  String? id;
  String? postedAt;
  String? projectId;
  String? taskId;
  Attachment? attachment;

  CommentsResponse(
      {this.content,
      this.id,
      this.postedAt,
      this.projectId,
      this.taskId,
      this.attachment});

  CommentsResponse.fromJson(Map<String, dynamic> json) {
    content = json['content'];
    id = json['id'];
    postedAt = json['posted_at'];
    projectId = json['project_id'];
    taskId = json['task_id'];
    attachment = json['attachment'] != null
        ? Attachment.fromJson(json['attachment'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (content != null) {
      data['content'] = content;
    }
    if (id != null) {}
    data['id'] = id;
    if (projectId != null) {
      data['project_id'] = projectId;
    }
    if (postedAt != null) {
      data['posted_at'] = postedAt;
    }
    if (taskId != null) {
      data['task_id'] = taskId;
    }
    if (attachment != null) {
      data['attachment'] = attachment?.toJson();
    }
    return data;
  }

  CommentsResponse copyWith({
    String? id,
    String? content,
    String? taskId,
    String? postedAt,
  }) {
    return CommentsResponse(
      id: id ?? this.id,
      content: content ?? this.content,
      taskId: taskId ?? this.taskId,
      postedAt: postedAt ?? this.postedAt,
    );
  }
}

class Attachment {
  String? fileName;
  String? fileType;
  String? fileUrl;
  String? resourceType;

  Attachment({this.fileName, this.fileType, this.fileUrl, this.resourceType});

  Attachment.fromJson(Map<String, dynamic> json) {
    fileName = json['file_name'];
    fileType = json['file_type'];
    fileUrl = json['file_url'];
    resourceType = json['resource_type'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['file_name'] = fileName;
    data['file_type'] = fileType;
    data['file_url'] = fileUrl;
    data['resource_type'] = resourceType;
    return data;
  }
}
