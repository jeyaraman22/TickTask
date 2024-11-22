class TodoistTaskResponseData {
  String? id;
  String? assignerId;
  String? assigneeId;
  String? projectId;
  String? sectionId;
  String? parentId;
  int? order;
  String? content;
  String? description;
  bool? isCompleted;
  List<String>? labels;
  int? priority;
  int? commentCount;
  String? creatorId;
  String? createdAt;
  Due? due;
  String? url;
  String? duration;
  String? deadline;
  Duration? timeSpent;
  bool? isTimerRunning;
  String? category;
  TodoistTaskResponseData({
    this.id,
    this.assignerId,
    this.assigneeId,
    this.projectId,
    this.sectionId,
    this.parentId,
    this.order,
    this.content,
    this.description,
    this.isCompleted,
    this.labels,
    this.priority,
    this.commentCount,
    this.creatorId,
    this.createdAt,
    this.due,
    this.url,
    this.duration,
    this.deadline,
    this.timeSpent,
    this.isTimerRunning,
    this.category,
  });

  TodoistTaskResponseData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    assignerId = json['assigner_id'];
    assigneeId = json['assignee_id'];
    projectId = json['project_id'];
    sectionId = json['section_id'];
    parentId = json['parent_id'];
    order = json['order'];
    content = json['content'];
    description = json['description'];
    isCompleted = json['is_completed'];
    if (json['labels'] != null) {
      labels = <String>[];
      json['labels'].forEach((v) {
        labels!.add(v);
      });
    }
    priority = json['priority'];
    commentCount = json['comment_count'];
    creatorId = json['creator_id'];
    createdAt = json['created_at'];
    due = json['due'] != null ? Due.fromJson(json['due']) : null;
    url = json['url'];
    duration = json['duration'];
    deadline = json['deadline'];
    timeSpent = json['time_spent'] != null
        ? Duration(seconds: json['time_spent'])
        : null;
    isTimerRunning = json['is_timer_running'];
    category = json['category'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['assigner_id'] = assignerId;
    data['assignee_id'] = assigneeId;
    data['project_id'] = projectId;
    data['section_id'] = sectionId;
    data['parent_id'] = parentId;
    data['order'] = order;
    data['content'] = content;
    data['description'] = description;
    data['is_completed'] = isCompleted;
    if (labels != null) {
      data['labels'] = labels!.cast<String>();
    }
    data['priority'] = priority;
    data['comment_count'] = commentCount;
    data['creator_id'] = creatorId;
    data['created_at'] = createdAt;
    if (due != null) {
      data['due'] = due!.toJson();
    }
    data['url'] = url;
    data['duration'] = duration;
    data['deadline'] = deadline;
    data['time_spent'] = timeSpent?.inSeconds;
    data['is_timer_running'] = isTimerRunning;
    data['category'] = category;
    return data;
  }

  TodoistTaskResponseData copyWith({
    Duration? timeSpent,
    bool? isTimerRunning,
    List<String>? labels,
    String? category,
    bool? isCompleted,
  }) {
    return TodoistTaskResponseData(
      id: id,
      assignerId: assignerId,
      assigneeId: assigneeId,
      projectId: projectId,
      sectionId: sectionId,
      parentId: parentId,
      order: order,
      content: content,
      description: description,
      isCompleted: isCompleted ?? this.isCompleted,
      labels: labels,
      priority: priority,
      commentCount: commentCount,
      creatorId: creatorId,
      createdAt: createdAt,
      due: due,
      url: url,
      duration: duration,
      deadline: deadline,
      timeSpent: timeSpent ?? this.timeSpent,
      isTimerRunning: isTimerRunning ?? this.isTimerRunning,
      category: category,
    );
  }
}

class Due {
  String? date;
  String? string;
  String? lang;
  bool? isRecurring;

  Due({this.date, this.string, this.lang, this.isRecurring});

  Due.fromJson(Map<String, dynamic> json) {
    date = json['date'];
    string = json['string'];
    lang = json['lang'];
    isRecurring = json['is_recurring'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['date'] = date;
    data['string'] = string;
    data['lang'] = lang;
    data['is_recurring'] = isRecurring;
    return data;
  }
}
