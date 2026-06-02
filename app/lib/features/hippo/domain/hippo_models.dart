enum HippoMood { thriving, content, resting, needsLove }

extension HippoMoodX on HippoMood {
  static HippoMood fromString(String s) => switch (s) {
        'thriving' => HippoMood.thriving,
        'content' => HippoMood.content,
        'resting' => HippoMood.resting,
        _ => HippoMood.needsLove,
      };

  String get label => switch (this) {
        HippoMood.thriving => 'Thriving',
        HippoMood.content => 'Content',
        HippoMood.resting => 'Resting',
        HippoMood.needsLove => 'Needs Love',
      };

  String get emoji => switch (this) {
        HippoMood.thriving => '✨',
        HippoMood.content => '✦',
        HippoMood.resting => '😴',
        HippoMood.needsLove => '🫶',
      };

  String get speechBubble => switch (this) {
        HippoMood.thriving => "You're crushing it today! 🌟\nMilo is glowing with joy!",
        HippoMood.content => "You walked {steps} steps today 🌿\nMilo feels your energy!",
        HippoMood.resting => "Rest is good too 🌙\nMilo is relaxing with you.",
        HippoMood.needsLove => "Milo misses your energy 🫶\nEven a short walk helps!",
      };
}

class HippoProfile {
  final String id;
  final String name;
  final String colorHex;

  const HippoProfile({required this.id, required this.name, required this.colorHex});

  factory HippoProfile.fromJson(Map<String, dynamic> json) => HippoProfile(
        id: json['id'] as String,
        name: json['name'] as String,
        colorHex: json['color_hex'] as String,
      );
}

class HippoState {
  final HippoProfile hippo;
  final HippoMood mood;
  final double? steps;

  const HippoState({required this.hippo, required this.mood, this.steps});

  factory HippoState.fromJson(Map<String, dynamic> json) => HippoState(
        hippo: HippoProfile.fromJson(json['hippo'] as Map<String, dynamic>),
        mood: HippoMoodX.fromString(json['mood'] as String),
        steps: (json['summary']?['steps'] as num?)?.toDouble(),
      );
}
