class AvailabilityModel {
  final bool isAvailable;
  final String startTime; // Format: "HH:mm"
  final String endTime;   // Format: "HH:mm"
  final int slotDuration; // In minutes

  AvailabilityModel({
    this.isAvailable = false,
    this.startTime = "09:00",
    this.endTime = "17:00",
    this.slotDuration = 25,
  });

  Map<String, dynamic> toMap() {
    return {
      'isAvailable': isAvailable,
      'startTime': startTime,
      'endTime': endTime,
      'slotDuration': slotDuration,
    };
  }

  factory AvailabilityModel.fromMap(Map<String, dynamic> map) {
    return AvailabilityModel(
      isAvailable: map['isAvailable'] ?? false,
      startTime: map['startTime'] ?? "09:00",
      endTime: map['endTime'] ?? "17:00",
      slotDuration: map['slotDuration'] ?? 25,
    );
  }

  AvailabilityModel copyWith({
    bool? isAvailable,
    String? startTime,
    String? endTime,
    int? slotDuration,
  }) {
    return AvailabilityModel(
      isAvailable: isAvailable ?? this.isAvailable,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      slotDuration: slotDuration ?? this.slotDuration,
    );
  }
}
