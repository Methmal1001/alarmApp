class Trip {
  Trip({
    required this.id,
    required this.fromName,
    required this.fromLat,
    required this.fromLng,
    required this.toName,
    required this.toLat,
    required this.toLng,
    this.radiusMeters = 300,
    this.isActive = true,
  });

  final String id;
  String fromName;
  double fromLat;
  double fromLng;
  String toName;
  double toLat;
  double toLng;
  double radiusMeters;
  bool isActive;

  Map<String, dynamic> toJson() => {
        'id': id,
        'fromName': fromName,
        'fromLat': fromLat,
        'fromLng': fromLng,
        'toName': toName,
        'toLat': toLat,
        'toLng': toLng,
        'radiusMeters': radiusMeters,
        'isActive': isActive,
      };

  factory Trip.fromJson(Map<String, dynamic> json) => Trip(
        id: json['id'] as String,
        fromName: json['fromName'] as String,
        fromLat: (json['fromLat'] as num).toDouble(),
        fromLng: (json['fromLng'] as num).toDouble(),
        toName: json['toName'] as String,
        toLat: (json['toLat'] as num).toDouble(),
        toLng: (json['toLng'] as num).toDouble(),
        radiusMeters: (json['radiusMeters'] as num).toDouble(),
        isActive: json['isActive'] as bool,
      );
}
