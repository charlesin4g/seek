import Flutter
import UIKit
import CloudKit


@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    if let controller = window?.rootViewController as? FlutterViewController {
      let channel = FlutterMethodChannel(name: "com.seek/icloud_sync", binaryMessenger: controller.binaryMessenger)
      let status = FlutterEventChannel(name: "com.seek/icloud_sync_status", binaryMessenger: controller.binaryMessenger)
      let statusStreamHandler = IcloudStatusStreamHandler()
      status.setStreamHandler(statusStreamHandler)
      channel.setMethodCallHandler { [weak self] (call, result) in
        guard let self = self else { return }
        if call.method == "startFullSync" {
          guard let args = call.arguments as? [String: Any],
                let payloadJson = args["payload"] as? String,
                let mediaPaths = args["mediaPaths"] as? [String] else {
            result(FlutterError(code: "ARG", message: "Invalid arguments", details: nil))
            return
          }
          self.startFullSync(payloadJson: payloadJson, mediaPaths: mediaPaths, statusHandler: statusStreamHandler) { ok, err in
            if ok { result(nil) } else { result(FlutterError(code: "SYNC", message: err ?? "sync failed", details: nil)) }
          }
        } else {
          result(FlutterMethodNotImplemented)
        }
      }
    }
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}

class IcloudStatusStreamHandler: NSObject, FlutterStreamHandler {
  private var sink: FlutterEventSink?
  func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
    sink = events
    return nil
  }
  func onCancel(withArguments arguments: Any?) -> FlutterError? {
    sink = nil
    return nil
  }
  func send(_ event: [String: Any]) {
    sink?(event)
  }
}

extension AppDelegate {
  func startFullSync(payloadJson: String, mediaPaths: [String], statusHandler: IcloudStatusStreamHandler, completion: @escaping (Bool, String?) -> Void) {
    CKContainer.default().accountStatus { status, error in
      DispatchQueue.main.async {
        if status != .available {
          statusHandler.send(["state": "disabled"])
          completion(false, "iCloud unavailable")
          return
        }
        self.syncStructuredData(payloadJson: payloadJson, statusHandler: statusHandler) { ok1, err1 in
          if !ok1 {
            completion(false, err1)
            return
          }
          self.syncMediaFiles(paths: mediaPaths, statusHandler: statusHandler) { ok2, err2 in
            completion(ok2, err2)
          }
        }
      }
    }
  }

  private func syncStructuredData(payloadJson: String, statusHandler: IcloudStatusStreamHandler, completion: @escaping (Bool, String?) -> Void) {
    statusHandler.send(["state": "progress", "progress": 0.05, "message": "上传结构化数据"])
    let db = CKContainer.default().privateCloudDatabase
    let tmpURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("seek_sync_payload.json")
    do {
      try payloadJson.data(using: .utf8)?.write(to: tmpURL)
    } catch {
      completion(false, "write temp failed: \(error)")
      return
    }
    let record = CKRecord(recordType: "SeekSyncPayload")
    record["createdAt"] = Date() as CKRecordValue
    record["payload"] = CKAsset(fileURL: tmpURL)
    db.save(record) { _, err in
      DispatchQueue.main.async {
        if let err = err {
          completion(false, "cloudkit save failed: \(err)")
        } else {
          statusHandler.send(["state": "progress", "progress": 0.2, "message": "结构化数据已上传"])
          completion(true, nil)
        }
      }
    }
  }

  private func syncMediaFiles(paths: [String], statusHandler: IcloudStatusStreamHandler, completion: @escaping (Bool, String?) -> Void) {
    guard let ubiq = FileManager.default.url(forUbiquityContainerIdentifier: nil) else {
      statusHandler.send(["state": "error", "message": "iCloud Drive未配置"])
      completion(false, "no ubiquity container")
      return
    }
    let destDir = ubiq.appendingPathComponent("Documents/SeekUploads", isDirectory: true)
    do {
      try FileManager.default.createDirectory(at: destDir, withIntermediateDirectories: true)
    } catch {}
    var copied = 0
    let total = paths.count
    func sendProgress() {
      let ratio = total == 0 ? 1.0 : Double(copied) / Double(total)
      statusHandler.send(["state": "progress", "progress": 0.2 + 0.8 * ratio, "message": "媒体文件同步 \(copied)/\(total)"])
    }
    let queue = DispatchQueue.global(qos: .utility)
    queue.async {
      for p in paths {
        let src = URL(fileURLWithPath: p)
        let fname = src.lastPathComponent
        let dst = destDir.appendingPathComponent(fname)
        do {
          if FileManager.default.fileExists(atPath: dst.path) {
            let srcSize = (try? FileManager.default.attributesOfItem(atPath: src.path)[.size] as? NSNumber)?.int64Value ?? 0
            let dstSize = (try? FileManager.default.attributesOfItem(atPath: dst.path)[.size] as? NSNumber)?.int64Value ?? 0
            if srcSize == dstSize { copied += 1; DispatchQueue.main.async { sendProgress() }; continue }
          }
          try self.copyLargeFileWithResume(from: src, to: dst) { _ in }
          copied += 1
          DispatchQueue.main.async { sendProgress() }
        } catch {
          DispatchQueue.main.async {
            statusHandler.send(["state": "error", "message": "文件复制失败: \(error)"])
          }
        }
      }
      DispatchQueue.main.async {
        statusHandler.send(["state": "success"])
        completion(true, nil)
      }
    }
  }

  private func copyLargeFileWithResume(from src: URL, to dst: URL, progress: @escaping (Double) -> Void) throws {
    let fm = FileManager.default
    if !fm.fileExists(atPath: dst.path) { fm.createFile(atPath: dst.path, contents: nil) }
    let inHandle = try FileHandle(forReadingFrom: src)
    let outHandle = try FileHandle(forWritingTo: dst)
    let existingSize = (try? fm.attributesOfItem(atPath: dst.path)[.size] as? NSNumber)?.int64Value ?? 0
    try outHandle.seek(toOffset: UInt64(existingSize))
    let chunkSize = 1_048_576
    var totalCopied: Int64 = existingSize
    let fileSize = (try? fm.attributesOfItem(atPath: src.path)[.size] as? NSNumber)?.int64Value ?? 0
    while autoreleasepool(invoking: {
      let data = try? inHandle.read(upToCount: chunkSize)
      if let d = data, d.count > 0 {
        outHandle.write(d)
        totalCopied += Int64(d.count)
        progress(Double(totalCopied) / Double(max(fileSize, 1)))
        return true
      }
      return false
    }) {}
    try outHandle.close()
    try inHandle.close()
  }
}
