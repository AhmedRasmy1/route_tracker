class RoutesModifires {
  bool? avoidTolls;
  bool? avoidHighways;
  bool? avoidFerries;

  RoutesModifires({
    this.avoidTolls = false,
    this.avoidHighways = false,
    this.avoidFerries = false,
  });

  factory RoutesModifires.fromJson(Map<String, dynamic> json) {
    return RoutesModifires(
      avoidTolls: json['avoidTolls'] as bool?,
      avoidHighways: json['avoidHighways'] as bool?,
      avoidFerries: json['avoidFerries'] as bool?,
    );
  }

  Map<String, dynamic> toJson() => {
    'avoidTolls': avoidTolls,
    'avoidHighways': avoidHighways,
    'avoidFerries': avoidFerries,
  };
}
