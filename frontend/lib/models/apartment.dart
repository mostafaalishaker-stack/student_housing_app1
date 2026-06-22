class Apartment {
  final String id;
  final String title;
  final String description;
  final double price;
  final String location;
  final String district;
  final int bedrooms;
  final int bathrooms;
  final double? area;
  final List<String> images;
  final List<String> amenities;
  final bool available;
  final String gender;
  final bool furnished;
  final int totalRooms;
  final int totalBeds;
  final int availableRooms;
  final int availableBeds;
  final double? pricePerRoom;
  final double? pricePerBed;
  final bool allowRoomBooking;
  final bool allowBedBooking;
  final DateTime? createdAt;

  Apartment({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.location,
    required this.district,
    required this.bedrooms,
    required this.bathrooms,
    this.area,
    required this.images,
    required this.amenities,
    required this.available,
    required this.gender,
    required this.furnished,
    required this.totalRooms,
    required this.totalBeds,
    required this.availableRooms,
    required this.availableBeds,
    this.pricePerRoom,
    this.pricePerBed,
    required this.allowRoomBooking,
    required this.allowBedBooking,
    this.createdAt,
  });

  factory Apartment.fromJson(Map<String, dynamic> json) {
    return Apartment(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      location: json['location'] ?? '',
      district: json['district'] ?? '',
      bedrooms: json['bedrooms'] ?? 1,
      bathrooms: json['bathrooms'] ?? 1,
      area: json['area']?.toDouble(),
      images: (json['images'] as List?)?.cast<String>() ?? [],
      amenities: (json['amenities'] as List?)?.cast<String>() ?? [],
      available: json['available'] ?? true,
      gender: json['gender'] ?? 'any',
      furnished: json['furnished'] ?? false,
      totalRooms: json['totalRooms'] ?? 1,
      totalBeds: json['totalBeds'] ?? 2,
      availableRooms: json['availableRooms'] ?? 1,
      availableBeds: json['availableBeds'] ?? 2,
      pricePerRoom: json['pricePerRoom']?.toDouble(),
      pricePerBed: json['pricePerBed']?.toDouble(),
      allowRoomBooking: json['allowRoomBooking'] ?? false,
      allowBedBooking: json['allowBedBooking'] ?? false,
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'title': title,
    'description': description,
    'price': price,
    'location': location,
    'district': district,
    'bedrooms': bedrooms,
    'bathrooms': bathrooms,
    'area': area,
    'images': images,
    'amenities': amenities,
    'available': available,
    'gender': gender,
    'furnished': furnished,
    'totalRooms': totalRooms,
    'totalBeds': totalBeds,
    'availableRooms': availableRooms,
    'availableBeds': availableBeds,
    'pricePerRoom': pricePerRoom,
    'pricePerBed': pricePerBed,
    'allowRoomBooking': allowRoomBooking,
    'allowBedBooking': allowBedBooking,
  };
}
