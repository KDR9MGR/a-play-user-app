import 'package:equatable/equatable.dart';

class TicketType {
  final String name;
  final double price;
  final int quantity;

  TicketType({
    required this.name,
    required this.price,
    required this.quantity,
  });

  factory TicketType.fromMap(Map<String, dynamic> map) {
    return TicketType(
      name: map['name'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      quantity: map['quantity'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'price': price,
      'quantity': quantity,
    };
  }
}

class ZoneModel extends Equatable {
  final String? id;
  final int capacity;
  final String name;
  final List<TicketType> ticketTypes;

  const ZoneModel({
    this.id,
    required this.capacity,
    required this.name,
    required this.ticketTypes,
  });

  factory ZoneModel.fromMap(Map<String, dynamic> map) {
    return ZoneModel(
      id: map['id'],
      capacity: map['capacity'] ?? 0,
      name: map['name'] ?? '',
      ticketTypes: List<TicketType>.from(
        (map['ticketTypes'] as List? ?? []).map(
          (x) => TicketType.fromMap(x as Map<String, dynamic>),
        ),
      ),
    );
  }

  //From Json
  factory ZoneModel.fromJson(Map<String, dynamic> json) {
    return ZoneModel.fromMap(json);
  }

  Map<String, dynamic> toMap() {
    final map = {
      'capacity': capacity,
      'name': name,
      'ticketTypes': ticketTypes.map((x) => x.toMap()).toList(),
    };
    
    // Don't include id in the map as it's the document ID
    return map;
  }

  @override
  List<Object?> get props => [id, capacity, name, ticketTypes];

  ZoneModel copyWith({
    String? id,
    int? capacity,
    String? name,
    List<TicketType>? ticketTypes,
  }) {
    return ZoneModel(
      id: id ?? this.id,
      capacity: capacity ?? this.capacity,
      name: name ?? this.name,
      ticketTypes: ticketTypes ?? this.ticketTypes,
    );
  }
}