import 'dart:convert' show json;
import 'package:flutter/services.dart' show rootBundle;

class CodePage {
  CodePage(this.id, this.name);
  final int id;
  final String name;
}

class CapabilityProfile {
  CapabilityProfile._internal(this.name, this.codePages);

  /// Public factory
  static Future<CapabilityProfile> load({String name = 'default'}) async {
    final String content;
    try {
      content = await rootBundle.loadString(
          'packages/flutter_esc_pos_utils/resources/capabilities.json');
    } catch (e) {
      throw Exception(
          'Failed to load capabilities.json. '
          'Ensure the asset is declared in pubspec.yaml: $e');
    }

    final Map capabilities;
    try {
      capabilities = json.decode(content);
    } catch (e) {
      throw Exception('Failed to parse capabilities.json: invalid JSON ($e)');
    }

    if (capabilities['profiles'] == null) {
      throw Exception(
          'capabilities.json is missing the "profiles" key');
    }

    var profile = capabilities['profiles'][name];

    if (profile == null) {
      throw Exception("The CapabilityProfile '$name' does not exist");
    }

    List<CodePage> list = [];
    profile['codePages'].forEach((k, v) {
      list.add(CodePage(int.parse(k), v));
    });

    // Call the private constructor
    return CapabilityProfile._internal(name, list);
  }

  final String name;
  final List<CodePage> codePages;

  int getCodePageId(String? codePage) {
    return codePages
        .firstWhere((cp) => cp.name == codePage,
            orElse: () => throw Exception(
                "Code Page '$codePage' isn't defined for this profile"))
        .id;
  }

  static Future<List<dynamic>> getAvailableProfiles() async {
    final String content;
    try {
      content = await rootBundle.loadString(
          'packages/flutter_esc_pos_utils/resources/capabilities.json');
    } catch (e) {
      throw Exception(
          'Failed to load capabilities.json. '
          'Ensure the asset is declared in pubspec.yaml: $e');
    }

    final Map capabilities;
    try {
      capabilities = json.decode(content);
    } catch (e) {
      throw Exception('Failed to parse capabilities.json: invalid JSON ($e)');
    }

    var profiles = capabilities['profiles'];
    if (profiles == null) {
      return [];
    }

    List<dynamic> res = [];

    profiles.forEach((k, v) {
      res.add({
        'key': k,
        'vendor': v['vendor'] is String ? v['vendor'] : '',
        'model': v['model'] is String ? v['model'] : '',
        'description': v['description'] is String ? v['description'] : '',
      });
    });

    return res;
  }
}
