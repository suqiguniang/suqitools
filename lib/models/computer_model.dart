class ComputerModel {
  final String id;
  final String name;
  final String ipAddress;
  final String macAddress;
  bool isOnline;

  ComputerModel({
    required this.id,
    required this.name,
    required this.ipAddress,
    required this.macAddress,
    this.isOnline = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'ipAddress': ipAddress,
      'macAddress': macAddress,
      'isOnline': isOnline,
    };
  }

  factory ComputerModel.fromJson(Map<String, dynamic> json) {
    return ComputerModel(
      id: json['id'],
      name: json['name'],
      ipAddress: json['ipAddress'],
      macAddress: json['macAddress'],
      isOnline: json['isOnline'] ?? false,
    );
  }

  ComputerModel copyWith({
    String? id,
    String? name,
    String? ipAddress,
    String? macAddress,
    bool? isOnline,
  }) {
    return ComputerModel(
      id: id ?? this.id,
      name: name ?? this.name,
      ipAddress: ipAddress ?? this.ipAddress,
      macAddress: macAddress ?? this.macAddress,
      isOnline: isOnline ?? this.isOnline,
    );
  }
}
