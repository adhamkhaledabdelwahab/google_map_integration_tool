import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:google_map_integration_tool/utils/utils.dart';
import 'package:process_run/process_run.dart';

class IntegrationToolScreen extends StatefulWidget {
  const IntegrationToolScreen({super.key});

  @override
  State<IntegrationToolScreen> createState() => _IntegrationToolScreenState();
}

class _IntegrationToolScreenState extends State<IntegrationToolScreen> {
  final TextEditingController _apiKeyController = TextEditingController();
  final _statusMessages = ListListenable();
  String? _selectedProjectPath;
  String? _apiKey;

  @override
  initState() {
    super.initState();
    _apiKeyController.addListener(() {
      if (_validateApiKeyFormat(_apiKeyController.text.trim()) == null) {
        setState(() {
          _apiKey = _apiKeyController.text;
        });
      }
    });
  }

  Future<void> _selectProjectDirectory() async {
    final directory = await getDirectoryPath();
    if (directory != null) {
      final pubspec = File('$directory/pubspec.yaml');

      if (pubspec.existsSync()) {
        setState(() {
          _selectedProjectPath = directory;
        });
        _statusMessages.addStatusMessage(
          AppStatus(
            StatusMessageType.projectDirectory,
            StatusMessage.success,
            '✅ Valid Flutter project selected!',
          ),
        );
      } else {
        _statusMessages.addStatusMessage(
          AppStatus(
            StatusMessageType.projectDirectory,
            StatusMessage.error,
            '❌ Error: Not a valid Flutter project.',
          ),
        );
      }
    }
  }

  Future<void> _integratePackage() async {
    if (_selectedProjectPath == null) {
      _statusMessages.addStatusMessage(
        AppStatus(
          StatusMessageType.integrateGooglePackage,
          StatusMessage.error,
          '❌ Error: Select a project first.',
        ),
      );
      return;
    }

    bool packageAdded = false;
    final pubspecPath = '$_selectedProjectPath/pubspec.yaml';
    final pubspecContent = File(pubspecPath).readAsStringSync();

    if (!pubspecContent.contains('google_maps_flutter')) {
      packageAdded = true;
      await run(
        'flutter pub add google_maps_flutter',
        workingDirectory: _selectedProjectPath,
      );
      _statusMessages.addStatusMessage(
        AppStatus(
          StatusMessageType.integrateGooglePackage,
          StatusMessage.success,
          '✅ Added google_maps_flutter to pubspec.yaml',
        ),
      );
    } else {
      _statusMessages.addStatusMessage(
        AppStatus(
          StatusMessageType.integrateGooglePackage,
          StatusMessage.error,
          '❌ Error: google_maps_flutter already exists in pubspec.yaml',
        ),
      );
    }

    if (!pubspecContent.contains('flutter_dotenv')) {
      packageAdded = true;
      await run(
        'flutter pub add flutter_dotenv',
        workingDirectory: _selectedProjectPath,
      );

      _statusMessages.addStatusMessage(
        AppStatus(
          StatusMessageType.integrateEnvPackage,
          StatusMessage.success,
          '✅ Added flutter_dotenv to pubspec.yaml',
        ),
      );
    } else {
      _statusMessages.addStatusMessage(
        AppStatus(
          StatusMessageType.integrateEnvPackage,
          StatusMessage.error,
          '❌ Error: flutter_dotenv already exists in pubspec.yaml',
        ),
      );
    }

    if (!pubspecContent.contains('flutter_riverpod')) {
      packageAdded = true;
      await run(
        'flutter pub add flutter_riverpod',
        workingDirectory: _selectedProjectPath,
      );

      _statusMessages.addStatusMessage(
        AppStatus(
          StatusMessageType.integrateRiverpodPackage,
          StatusMessage.success,
          '✅ Added flutter_riverpod to pubspec.yaml',
        ),
      );
    } else {
      _statusMessages.addStatusMessage(
        AppStatus(
          StatusMessageType.integrateRiverpodPackage,
          StatusMessage.error,
          '❌ Error: flutter_riverpod already exists in pubspec.yaml',
        ),
      );
    }

    if (packageAdded) {
      await run('flutter pub get', workingDirectory: _selectedProjectPath);
    }
  }

  void _saveApiKey() {
    if (_selectedProjectPath == null) {
      _statusMessages.addStatusMessage(
        AppStatus(
          StatusMessageType.saveApiKey,
          StatusMessage.error,
          '❌ Error: Select a project first.',
        ),
      );
      return;
    } else if (_apiKey == null) {
      _statusMessages.addStatusMessage(
        AppStatus(
          StatusMessageType.saveApiKey,
          StatusMessage.error,
          '❌ Error: Add google map api key first.',
        ),
      );
      return;
    }
    final envFile = File('$_selectedProjectPath/.env');
    if (!envFile.existsSync() ||
        !envFile.readAsStringSync().contains("GOOGLE_MAPS_API_KEY")) {
      envFile.writeAsStringSync('GOOGLE_MAPS_API_KEY=$_apiKey');
      _statusMessages.addStatusMessage(
        AppStatus(
          StatusMessageType.saveApiKey,
          StatusMessage.success,
          '✅ API key saved to .env',
        ),
      );
    } else {
      _statusMessages.addStatusMessage(
        AppStatus(
          StatusMessageType.saveApiKey,
          StatusMessage.error,
          '❌ Error: API key already exists in .env',
        ),
      );
    }
  }

  void _configureAndroid() {
    if (_selectedProjectPath == null) {
      _statusMessages.addStatusMessage(
        AppStatus(
          StatusMessageType.configureAndroid,
          StatusMessage.error,
          '❌ Error: Select a project first.',
        ),
      );
      return;
    } else if (_apiKey == null) {
      _statusMessages.addStatusMessage(
        AppStatus(
          StatusMessageType.configureAndroid,
          StatusMessage.error,
          '❌ Error: Add google map api key first.',
        ),
      );
      return;
    }
    final manifestPath =
        '$_selectedProjectPath/android/app/src/main/AndroidManifest.xml';
    final manifestContent = File(manifestPath).readAsStringSync();
    if (!manifestContent.contains('com.google.android.geo.API_KEY')) {
      final updatedContent = manifestContent.replaceFirst(
        '</application>',
        '<meta-data\n    android:name="com.google.android.geo.API_KEY"\n    android:value="$_apiKey"/>\n</application>',
      );
      File(manifestPath).writeAsStringSync(updatedContent);
      _statusMessages.addStatusMessage(
        AppStatus(
          StatusMessageType.configureAndroid,
          StatusMessage.success,
          '✅ Configured AndroidManifest.xml',
        ),
      );
    } else {
      _statusMessages.addStatusMessage(
        AppStatus(
          StatusMessageType.configureAndroid,
          StatusMessage.error,
          '❌ Error: API key already exists in AndroidManifest.xml',
        ),
      );
    }
  }

  void _configureIos() {
    if (_selectedProjectPath == null) {
      _statusMessages.addStatusMessage(
        AppStatus(
          StatusMessageType.configureIos,
          StatusMessage.error,
          '❌ Error: Select a project first.',
        ),
      );
      return;
    } else if (_apiKey == null) {
      _statusMessages.addStatusMessage(
        AppStatus(
          StatusMessageType.configureIos,
          StatusMessage.error,
          '❌ Error: Add google map api key first.',
        ),
      );

      return;
    }
    final plistPath = '$_selectedProjectPath/ios/Runner/Info.plist';
    final plistContent = File(plistPath).readAsStringSync();
    if (!plistContent.contains('GoogleMapsAPIKey')) {
      final updatedContent = plistContent.replaceFirst(
        '</dict>',
        '<key>GoogleMapsAPIKey</key>\n<string>$_apiKey</string>\n</dict>',
      );
      File(plistPath).writeAsStringSync(updatedContent);
      _statusMessages.addStatusMessage(
        AppStatus(
          StatusMessageType.configureIos,
          StatusMessage.success,
          '✅ Configured Info.plist',
        ),
      );
    } else {
      _statusMessages.addStatusMessage(
        AppStatus(
          StatusMessageType.configureIos,
          StatusMessage.error,
          '❌ Error: API key already exists in Info.plist',
        ),
      );
    }
  }

  String? _validateApiKeyFormat(String? apiKey) {
    if (apiKey == null || apiKey.trim().isEmpty) return null;
    final regex = RegExp(r'^AIza[0-9A-Za-z_-]{35}$');
    if (!regex.hasMatch(apiKey.trim())) {
      return "❌ Error: Invalid API key format.";
    }
    return null;
  }

  void _addExampleCode() {
    final exampleCode = '''
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final cameraPositionProvider = StateProvider<CameraPosition>((ref) {
  return CameraPosition(
    target: LatLng(37.7749, -122.4194),
    zoom: 12,
  );
});

class MapScreen extends ConsumerWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cameraPosition = ref.watch(cameraPositionProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Google Maps Demo')),
      body: GoogleMap(
        initialCameraPosition: cameraPosition,
        onMapCreated: (controller) {},
        onCameraMove: (position) {
          ref.read(cameraPositionProvider.notifier).state = position;
        },
      ),
    );
  }
}
''';

    // Save to lib/map_screen.dart
    final main = File('$_selectedProjectPath/lib/main.dart');
    if (!main.readAsStringSync().contains(
      "package:flutter_dotenv/flutter_dotenv.dart",
    )) {
      main.writeAsStringSync(
        '''import 'package:flutter_dotenv/flutter_dotenv.dart';\n${main.readAsStringSync()}''',
      );
    }
    if (!main.readAsStringSync().contains(
      "package:flutter_riverpod/flutter_riverpod.dart",
    )) {
      main.writeAsStringSync(
        '''import 'package:flutter_riverpod/flutter_riverpod.dart';\n${main.readAsStringSync()}''',
      );
    }
    if (main.readAsStringSync().contains("runApp(MyApp());") ||
        main.readAsStringSync().contains("runApp(const MyApp());")) {
      final result = main.readAsStringSync().replaceFirst(
        main.readAsStringSync().contains("runApp(MyApp());")
            ? "runApp(MyApp());"
            : "runApp(const MyApp());",
        "dotenv.load();\nrunApp(ProviderScope(child: const MyApp()));",
      );
      main.writeAsStringSync(result);
    }

    final mapScreen = File('$_selectedProjectPath/lib/map_screen.dart');
    if (!mapScreen.existsSync() || mapScreen.readAsStringSync().isEmpty) {
      mapScreen.writeAsStringSync(exampleCode);
      _statusMessages.addStatusMessage(
        AppStatus(
          StatusMessageType.addExampleCode,
          StatusMessage.success,
          '✅ Example code added to lib/map_screen.dart',
        ),
      );
    } else {
      _statusMessages.addStatusMessage(
        AppStatus(
          StatusMessageType.addExampleCode,
          StatusMessage.error,
          '❌ Error: Example code already exists in lib/map_screen.dart',
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Flutter Package Integrator')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade700,
                padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: _selectProjectDirectory,
              child: const Text(
                'Select Flutter Project Directory',
                style: TextStyle(color: Colors.white),
              ),
            ),
            if (_selectedProjectPath != null) const SizedBox(height: 20),
            if (_selectedProjectPath != null)
              Text(
                'Selected Project: $_selectedProjectPath',
                style: const TextStyle(fontSize: 16, color: Colors.black),
              ),
            const SizedBox(height: 20),
            ValueListenableBuilder(
              valueListenable: _apiKeyController,
              builder: (context, apiKeyValue, child) {
                final validateApiKey =
                    _validateApiKeyFormat(apiKeyValue.text.trim()) == null;
                return TextField(
                  enabled: _selectedProjectPath != null,
                  controller: _apiKeyController,
                  decoration: InputDecoration(
                    labelText: 'Google Maps API Key',
                    hintText: 'Enter your API key here',
                    errorText: _validateApiKeyFormat(_apiKey),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: BorderSide(width: 1, color: Colors.grey),
                    ),
                    suffixIcon:
                        apiKeyValue.text.trim().isNotEmpty
                            ? Icon(
                              validateApiKey ? Icons.check : Icons.close,
                              color: validateApiKey ? Colors.green : Colors.red,
                            )
                            : null,
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 20,
              runSpacing: 20,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade700,
                    padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed:
                      _selectedProjectPath == null ? null : _integratePackage,
                  child: Text(
                    'Integrate Google Maps Package',
                    style: TextStyle(
                      color:
                          _selectedProjectPath == null
                              ? Colors.grey.shade500
                              : Colors.white,
                    ),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade700,
                    padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed:
                      _apiKey == null || _selectedProjectPath == null
                          ? null
                          : () {
                            _saveApiKey();
                            _configureAndroid();
                            _configureIos();
                          },
                  child: Text(
                    'Configure Platforms',
                    style: TextStyle(
                      color:
                          _apiKey == null || _selectedProjectPath == null
                              ? Colors.grey.shade500
                              : Colors.white,
                    ),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade700,
                    padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed:
                      _selectedProjectPath == null ? null : _addExampleCode,
                  child: Text(
                    'Add Example Code',
                    style: TextStyle(
                      color:
                          _selectedProjectPath == null
                              ? Colors.grey.shade500
                              : Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListenableBuilder(
                listenable: _statusMessages,
                builder: (context, child) {
                  final statusMessages = _statusMessages.statusMessages;
                  return ListView.builder(
                    itemCount: statusMessages.length,
                    itemBuilder: (context, index) {
                      return Text(
                        statusMessages[index].message,
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 17,
                          color:
                              statusMessages[index].status ==
                                      StatusMessage.error
                                  ? Colors.red
                                  : Colors.green,
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
