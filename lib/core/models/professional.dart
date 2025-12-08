enum ProfessionalType {
  doctor,
  dentist,
  psychologist,
  other,
}

class Professional {
  final String id;
  final String name;
  final String specialty; // For doctors/dentists this is specialty, for psychologists this is focus.
  final String city;
  final double rating;
  final double price; // Standardized price field
  final String? photoUrl;
  final int yearsExperience;
  final List<String> insurance;

  final ProfessionalType type;

  // Extra fields that might be null for some types
  final String? address;
  final String? bio;
  final bool isTelemedicine;
  final List<String> languages;
  final List<String> hospitals;

  // Doctor specific fields (standardized)
  final bool acceptsEmergencies; // atiendeUrgencias
  final bool acceptsHomeVisits; // atiendeDomicilio
  final double? virtualPrice; // precioConsultaVirtual
  final List<String> schedules; // horarios (matutino, vespertino...)
  final List<String> modalities; // presencial, virtual

  // Premium Status
  final bool isPremium;

  Professional({
    required this.id,
    required this.name,
    required this.specialty,
    required this.city,
    required this.rating,
    required this.price,
    this.photoUrl,
    this.yearsExperience = 0,
    this.insurance = const [],
    this.type = ProfessionalType.doctor,
    this.address,
    this.bio,
    this.isTelemedicine = false,
    this.languages = const [],
    this.hospitals = const [],
    this.acceptsEmergencies = false,
    this.acceptsHomeVisits = false,
    this.virtualPrice,
    this.schedules = const [],
    this.modalities = const [],
    this.isPremium = false,
  });

  factory Professional.fromJson(Map<String, dynamic> json) {
    return Professional(
      id: json['id'] as String,
      name: json['name'] as String,
      specialty: json['specialty'] as String,
      city: json['city'] as String,
      rating: (json['rating'] as num).toDouble(),
      price: (json['price'] as num).toDouble(),
      photoUrl: json['photoUrl'] as String?,
      yearsExperience: json['yearsExperience'] as int? ?? 0,
      insurance: (json['insurance'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
      type: ProfessionalType.values.firstWhere(
        (e) => e.toString() == 'ProfessionalType.${json['type']}',
        orElse: () => ProfessionalType.doctor,
      ),
      address: json['address'] as String?,
      bio: json['bio'] as String?,
      isTelemedicine: json['isTelemedicine'] as bool? ?? false,
      languages: (json['languages'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
      hospitals: (json['hospitals'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
      acceptsEmergencies: json['acceptsEmergencies'] as bool? ?? false,
      acceptsHomeVisits: json['acceptsHomeVisits'] as bool? ?? false,
      virtualPrice: (json['virtualPrice'] as num?)?.toDouble(),
      schedules: (json['schedules'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
      modalities: (json['modalidades'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
      isPremium: json['isPremium'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'specialty': specialty,
      'city': city,
      'rating': rating,
      'price': price,
      'photoUrl': photoUrl,
      'yearsExperience': yearsExperience,
      'insurance': insurance,
      'type': type.toString().split('.').last,
      'address': address,
      'bio': bio,
      'isTelemedicine': isTelemedicine,
      'languages': languages,
      'hospitals': hospitals,
      'acceptsEmergencies': acceptsEmergencies,
      'acceptsHomeVisits': acceptsHomeVisits,
      'virtualPrice': virtualPrice,
      'schedules': schedules,
      'modalities': modalities,
      'isPremium': isPremium,
    };
  }

  Professional copyWith({
    String? id,
    String? name,
    String? specialty,
    String? city,
    double? rating,
    double? price,
    String? photoUrl,
    int? yearsExperience,
    List<String>? insurance,
    ProfessionalType? type,
    String? address,
    String? bio,
    bool? isTelemedicine,
    List<String>? languages,
    List<String>? hospitals,
    bool? acceptsEmergencies,
    bool? acceptsHomeVisits,
    double? virtualPrice,
    List<String>? schedules,
    List<String>? modalities,
    bool? isPremium,
  }) {
    return Professional(
      id: id ?? this.id,
      name: name ?? this.name,
      specialty: specialty ?? this.specialty,
      city: city ?? this.city,
      rating: rating ?? this.rating,
      price: price ?? this.price,
      photoUrl: photoUrl ?? this.photoUrl,
      yearsExperience: yearsExperience ?? this.yearsExperience,
      insurance: insurance ?? this.insurance,
      type: type ?? this.type,
      address: address ?? this.address,
      bio: bio ?? this.bio,
      isTelemedicine: isTelemedicine ?? this.isTelemedicine,
      languages: languages ?? this.languages,
      hospitals: hospitals ?? this.hospitals,
      acceptsEmergencies: acceptsEmergencies ?? this.acceptsEmergencies,
      acceptsHomeVisits: acceptsHomeVisits ?? this.acceptsHomeVisits,
      virtualPrice: virtualPrice ?? this.virtualPrice,
      schedules: schedules ?? this.schedules,
      modalities: modalities ?? this.modalities,
      isPremium: isPremium ?? this.isPremium,
    );
  }
}
