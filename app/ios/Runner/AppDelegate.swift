import CryptoKit
import DeviceCheck
import Flutter
import StoreKit
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
    if let registrar = engineBridge.pluginRegistry.registrar(forPlugin: "RefundPlugin") {
      RefundPlugin.register(with: registrar)
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

/// Apple's own refund request sheet for lib/core/refund_service.dart. Apple
/// decides every refund; the app only opens the sheet for a purchase.
final class RefundPlugin: NSObject, FlutterPlugin {
  static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(
      name: "shentarot/refund", binaryMessenger: registrar.messenger())
    registrar.addMethodCallDelegate(RefundPlugin(), channel: channel)
  }

  func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "recentPurchases":
      Task {
        // Newest first, last 90 days: older purchases are rarely refundable.
        let since = Date().addingTimeInterval(-90 * 24 * 3600)
        var items: [[String: Any]] = []
        for await entry in Transaction.all {
          guard case .verified(let t) = entry, t.revocationDate == nil,
            t.purchaseDate > since
          else { continue }
          items.append([
            "id": String(t.id),
            "productId": t.productID,
            "date": Int(t.purchaseDate.timeIntervalSince1970 * 1000),
          ])
        }
        items.sort { ($0["date"] as! Int) > ($1["date"] as! Int) }
        let list = Array(items.prefix(10))
        await MainActor.run { result(list) }
      }
    case "requestRefund":
      guard let idString = (call.arguments as? [String: Any])?["id"] as? String,
        let id = UInt64(idString)
      else {
        result(FlutterError(code: "bad_args", message: "id needed", details: nil))
        return
      }
      Task { @MainActor in
        guard
          let scene = UIApplication.shared.connectedScenes
            .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene
        else {
          result(FlutterError(code: "no_window", message: "No active window", details: nil))
          return
        }
        do {
          let status = try await Transaction.beginRefundRequest(for: id, in: scene)
          result(status == .success ? "success" : "cancelled")
        } catch {
          result(FlutterError(code: "failed", message: error.localizedDescription, details: nil))
        }
      }
    default:
      result(FlutterMethodNotImplemented)
    }
  }
}
