import Foundation
import SwiftUI

class ConfigViewHostingWrapperFactory: NSObject {
    @objc static func make(coder: NSCoder) -> UIViewController {
        return UIHostingController(coder: coder, rootView: ConfigView())!
    }
}
