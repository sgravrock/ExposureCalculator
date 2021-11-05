import Foundation
import SwiftUI

class ConfigViewHostingWrapperFactory: NSObject {
    @objc static func make(coder: NSCoder, supportedSettings: SupportedSettings) -> UIViewController {
        return UIHostingController(coder: coder, rootView: ConfigView(configuration: supportedSettings))!
    }
}
