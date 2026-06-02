import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../domain/hippo_models.dart';

class HippoRepository {
  Future<HippoState> get() async {
    final resp = await ApiClient.instance.get('/hippo');
    return HippoState.fromJson(resp.data as Map<String, dynamic>);
  }

  Future<HippoProfile> update({String? name, String? colorHex}) async {
    final resp = await ApiClient.instance.put('/hippo', data: {
      if (name != null) 'name': name,
      if (colorHex != null) 'color_hex': colorHex,
    });
    return HippoProfile.fromJson(resp.data as Map<String, dynamic>);
  }
}

final hippoRepositoryProvider = Provider((_) => HippoRepository());
