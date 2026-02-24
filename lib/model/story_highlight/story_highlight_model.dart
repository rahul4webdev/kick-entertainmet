class StoryHighlightsModel {
  bool? status;
  String? message;
  List<StoryHighlight>? data;

  StoryHighlightsModel({this.status, this.message, this.data});

  StoryHighlightsModel.fromJson(dynamic json) {
    status = json['status'];
    message = json['message'];
    if (json['data'] != null) {
      data = [];
      json['data'].forEach((v) {
        data!.add(StoryHighlight.fromJson(v));
      });
    }
  }
}

class StoryHighlightModel {
  bool? status;
  String? message;
  StoryHighlight? data;

  StoryHighlightModel({this.status, this.message, this.data});

  StoryHighlightModel.fromJson(dynamic json) {
    status = json['status'];
    message = json['message'];
    if (json['data'] != null) {
      data = StoryHighlight.fromJson(json['data']);
    }
  }
}

class StoryHighlight {
  int? id;
  int? userId;
  String? name;
  String? coverImage;
  int? sortOrder;
  int? itemCount;
  String? createdAt;
  String? updatedAt;
  List<StoryHighlightItem>? items;

  StoryHighlight({
    this.id,
    this.userId,
    this.name,
    this.coverImage,
    this.sortOrder,
    this.itemCount,
    this.createdAt,
    this.updatedAt,
    this.items,
  });

  StoryHighlight.fromJson(dynamic json) {
    id = json['id'];
    userId = json['user_id'];
    name = json['name'];
    coverImage = json['cover_image'];
    sortOrder = json['sort_order'];
    itemCount = json['item_count'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    if (json['items'] != null) {
      items = [];
      json['items'].forEach((v) {
        items!.add(StoryHighlightItem.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['user_id'] = userId;
    map['name'] = name;
    map['cover_image'] = coverImage;
    map['sort_order'] = sortOrder;
    map['item_count'] = itemCount;
    map['created_at'] = createdAt;
    map['updated_at'] = updatedAt;
    if (items != null) {
      map['items'] = items!.map((v) => v.toJson()).toList();
    }
    return map;
  }
}

class StoryHighlightItem {
  int? id;
  int? highlightId;
  int? originalStoryId;
  int? type;
  String? content;
  String? thumbnail;
  String? duration;
  int? sortOrder;
  String? createdAt;
  String? updatedAt;

  StoryHighlightItem({
    this.id,
    this.highlightId,
    this.originalStoryId,
    this.type,
    this.content,
    this.thumbnail,
    this.duration,
    this.sortOrder,
    this.createdAt,
    this.updatedAt,
  });

  StoryHighlightItem.fromJson(dynamic json) {
    id = json['id'];
    highlightId = json['highlight_id'];
    originalStoryId = json['original_story_id'];
    type = json['type'];
    content = json['content'];
    thumbnail = json['thumbnail'];
    duration = json['duration'];
    sortOrder = json['sort_order'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['highlight_id'] = highlightId;
    map['original_story_id'] = originalStoryId;
    map['type'] = type;
    map['content'] = content;
    map['thumbnail'] = thumbnail;
    map['duration'] = duration;
    map['sort_order'] = sortOrder;
    map['created_at'] = createdAt;
    map['updated_at'] = updatedAt;
    return map;
  }
}
