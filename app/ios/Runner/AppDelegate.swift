import CryptoKit
import DeviceCheck
import Flutter
import UIKit
import UserNotifications

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Lets the daily reminder show while the app is open.
    UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    if let registrar = engineBridge.pluginRegistry.registrar(forPlugin: "AppAttestPlugin") {
      AppAttestPlugin.register(with: registrar)
    }
  }
}

/// App Attest for lib/core/app_attest.dart: the key stays in the Secure Enclave,
/// Dart only sees its id, the attestation and the assertions (base64).
final class AppAttestPlugin: NSObject, FlutterPlugin {
  static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(
      name: "shentarot/app_attest", binaryMessenger: registrar.messenger())
    registrar.addMethodCallDelegate(AppAttestPlugin(), channel: channel)
  }

  func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    let service = DCAppAttestService.shared
    let args = call.arguments as? [String: Any] ?? [:]
    let keyId = args["keyId"] as? String
    let clientData = (args["clientData"] as? FlutterStandardTypedData)?.data
    let reply: (Any?, Error?) -> Void = { value, error in
      DispatchQueue.main.async {
        if let error = error as? DCError, error.code == .invalidKey {
          result(FlutterError(code: "invalid_key", message: error.localizedDescription, details: nil))
        } else if let error = error {
          result(FlutterError(code: "failed", message: error.localizedDescription, details: nil))
        } else {
          result(value)
        }
      }
    }
    switch call.method {
    case "isSupported":
      result(service.isSupported)
    case "generateKey":
      service.generateKey { id, error in reply(id, error) }
    case "attestKey", "generateAssertion":
      guard let keyId = keyId, let clientData = clientData else {
        result(FlutterError(code: "bad_args", message: "keyId and clientData needed", details: nil))
        return
      }
      let hash = Data(SHA256.hash(data: clientData))
      if call.method == "attestKey" {
        service.attestKey(keyId, clientDataHash: hash) { object, error in
          reply(object?.base64EncodedString(), error)
        }
      } else {
        service.generateAssertion(keyId, clientDataHash: hash) { assertion, error in
          reply(assertion?.base64EncodedString(), error)
        }
      }
    default:
      result(FlutterMethodNotImplemented)
    }
  }
}
