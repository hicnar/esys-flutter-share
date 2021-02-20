import Flutter
import UIKit

public class SwiftEsysFlutterSharePlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "channel:github.com/orgs/esysberlin/esys-flutter-share", binaryMessenger: registrar.messenger())
        let instance = SwiftEsysFlutterSharePlugin()
        
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        if(call.method == "text"){
            self.text(arguments: call.arguments)
        }
        if(call.method == "file"){
            self.file(arguments: call.arguments)
        }
        if(call.method == "files"){
            self.files(arguments: call.arguments)
        }
    }
    
    func text(arguments:Any?) -> Void {
        // prepare method channel args
        // no use in ios
        //// let title:String = argsMap.value(forKey: "title") as! String
        let argsMap = arguments as! NSDictionary
        let text:String = argsMap.value(forKey: "text") as! String
        let subject:String = argsMap.value(forKey: "subject") as! String

        if (UIDevice.current.userInterfaceIdiom == .pad) {
           setupAndShow(activityItems: [text], argsMap: argsMap, subject: subject)
        } else {
          // set up activity view controller
          let activityViewController:UIActivityViewController = UIActivityViewController(activityItems: [text], applicationActivities: nil)

          if (!subject.isEmpty) {
              activityViewController.setValue(subject, forKey: "Subject")
          }

          // present the view controller
          let controller = UIApplication.shared.keyWindow!.rootViewController
          activityViewController.popoverPresentationController?.sourceView = controller?.view
          controller?.present(activityViewController, animated: true, completion: nil)
        }
    }

    func file(arguments:Any?) -> Void {
        // prepare method channel args
        // no use in ios
        //// let title:String = argsMap.value(forKey: "title") as! String
        let argsMap = arguments as! NSDictionary
        let name:String = argsMap.value(forKey: "name") as! String
        let text:String = argsMap.value(forKey: "text") as! String
        let subject:String = argsMap.value(forKey: "subject") as! String
        let pluginDir:String = argsMap.value(forKey: "pluginDir") as! String

        // load the file from the plugin directory
        var docsPath:URL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!;
        
        if (!pluginDir.isEmpty) {
            docsPath.appendPathComponent(pluginDir, isDirectory: true);
        }
        
        let contentUri = NSURL(fileURLWithPath: docsPath.absoluteString).appendingPathComponent(name)

        // prepare activity items
        var activityItems:[Any] = [contentUri!];
        if (!text.isEmpty) {
            // add optional text
            activityItems.append(text);
        }
        if (UIDevice.current.userInterfaceIdiom == .pad) {
           setupAndShow(activityItems: activityItems, argsMap: argsMap, subject: subject)
        } else {
          // set up activity view controller
          let activityViewController:UIActivityViewController = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)

          // present the view controller
          let controller = UIApplication.shared.keyWindow!.rootViewController
          activityViewController.popoverPresentationController?.sourceView = controller?.view
          controller?.present(activityViewController, animated: true, completion: nil)
        }

    }

    func files(arguments:Any?) -> Void {
        // prepare method channel args
        // no use in ios
        //// let title:String = argsMap.value(forKey: "title") as! String
        let argsMap = arguments as! NSDictionary
        let names:[String] = argsMap.value(forKey: "names") as! [String]
        let text:String = argsMap.value(forKey: "text") as! String
        let subject:String = argsMap.value(forKey: "subject") as! String

        // prepare activity items
        var activityItems:[Any] = [];

        // load the files
        for name in names {
            let docsPath:String = NSSearchPathForDirectoriesInDomains(.cachesDirectory,.userDomainMask , true).first!;
            activityItems.append(NSURL(fileURLWithPath: docsPath).appendingPathComponent(name)!);
        }

        if (!text.isEmpty){
            // add optional text
            activityItems.append(text);
        }
        if (UIDevice.current.userInterfaceIdiom == .pad){
           setupAndShow(activityItems: activityItems, argsMap: argsMap, subject: subject)
        } else {
          // set up activity view controller
          let activityViewController:UIActivityViewController = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)

          // present the view controller
          let controller = UIApplication.shared.keyWindow!.rootViewController
          activityViewController.popoverPresentationController?.sourceView = controller?.view
          controller?.present(activityViewController, animated: true, completion: nil)
        }
    }

    private func setupAndShow(activityItems: [Any], argsMap: NSDictionary, subject: String) {
        
        let activityViewController = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
        
        if (!subject.isEmpty) {
            activityViewController.setValue(subject, forKey: "Subject")
        }

        let controller = UIApplication.shared.keyWindow!.rootViewController

        if let popover = activityViewController.popoverPresentationController {

            popover.sourceView = controller?.view
            let bounds = controller?.view.bounds

            if (UIDevice.current.userInterfaceIdiom == .pad) {

                let originX:NSNumber = argsMap.value(forKey: "originX") as? NSNumber ?? NSNumber(value: Float(bounds!.midX))
                let originY:NSNumber = argsMap.value(forKey: "originY") as? NSNumber ?? NSNumber(value: Float(bounds!.midY))
                var originWidth:NSNumber = argsMap.value(forKey: "originWidth") as? NSNumber ?? 0
                var originHeight:NSNumber = argsMap.value(forKey: "originHeight") as? NSNumber ?? 0

                if (originWidth.intValue > (bounds!.width - 96 as NSNumber).intValue) {
                    originWidth = NSNumber(value: Float((bounds!.width - 96)))
                }

                if (originHeight.intValue > (bounds!.height - 96 as NSNumber).intValue) {
                    originHeight = NSNumber(value: Float((bounds!.height - 96)))
                }

                popover.sourceRect = CGRect(x:originX.doubleValue,
                                            y:originY.doubleValue,
                                            width:originWidth.doubleValue,
                                            height:originHeight.doubleValue);
            }
            controller?.present(activityViewController, animated: true, completion: nil)
        }
    }
}
