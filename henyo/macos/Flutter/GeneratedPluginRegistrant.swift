//
//  Generated file. Do not edit.
//

import FlutterMacOS
import Foundation

import audio_session
import connectivity_plus
import just_audio
import objectbox_sync_flutter_libs
import package_info_plus
import path_provider_foundation
import record_darwin
import rive_common
import speech_to_text_macos

func RegisterGeneratedPlugins(registry: FlutterPluginRegistry) {
  AudioSessionPlugin.register(with: registry.registrar(forPlugin: "AudioSessionPlugin"))
  ConnectivityPlugin.register(with: registry.registrar(forPlugin: "ConnectivityPlugin"))
  JustAudioPlugin.register(with: registry.registrar(forPlugin: "JustAudioPlugin"))
  ObjectboxSyncFlutterLibsPlugin.register(with: registry.registrar(forPlugin: "ObjectboxSyncFlutterLibsPlugin"))
  FPPPackageInfoPlusPlugin.register(with: registry.registrar(forPlugin: "FPPPackageInfoPlusPlugin"))
  PathProviderPlugin.register(with: registry.registrar(forPlugin: "PathProviderPlugin"))
  RecordPlugin.register(with: registry.registrar(forPlugin: "RecordPlugin"))
  RivePlugin.register(with: registry.registrar(forPlugin: "RivePlugin"))
  SpeechToTextMacosPlugin.register(with: registry.registrar(forPlugin: "SpeechToTextMacosPlugin"))
}
