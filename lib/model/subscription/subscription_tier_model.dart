class SubscriptionTier {
  int? id;
  int? creatorId;
  String? name;
  int? priceCoins;
  String? description;
  List<String>? benefits;
  int? sortOrder;
  bool? isActive;

  SubscriptionTier({
    this.id,
    this.creatorId,
    this.name,
    this.priceCoins,
    this.description,
    this.benefits,
    this.sortOrder,
    this.isActive,
  });

  SubscriptionTier.fromJson(dynamic json) {
    id = json['id'];
    creatorId = json['creator_id'];
    name = json['name'];
    priceCoins = json['price_coins'];
    description = json['description'];
    benefits = json['benefits'] != null
        ? List<String>.from(json['benefits'])
        : null;
    sortOrder = json['sort_order'];
    isActive = json['is_active'];
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['creator_id'] = creatorId;
    map['name'] = name;
    map['price_coins'] = priceCoins;
    map['description'] = description;
    map['benefits'] = benefits;
    map['sort_order'] = sortOrder;
    map['is_active'] = isActive;
    return map;
  }
}
