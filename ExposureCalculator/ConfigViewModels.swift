class ConfigViewModel: ObservableObject {
    let pickerModels: [PickerViewModel]
    
    @Published var selectedModel: PickerViewModel
    
    @Published var selectedComponentIx = 0 {
        didSet {
            selectedModel = pickerModels[selectedComponentIx]
        }
    }
    
    init(configuration: SupportedSettings) {
        let apertureModel = PickerViewModel(configuration: configuration, componentIx: 0, settingName: "Aperture range")
        let shutterModel = PickerViewModel(configuration: configuration, componentIx: 1, settingName: "Shutter range")
        let isoModel = PickerViewModel(configuration: configuration, componentIx: 2, settingName: "ISO range")

        pickerModels = [apertureModel, shutterModel, isoModel]
        selectedComponentIx = 0
        selectedModel = apertureModel
    }
}

class PickerViewModel: ObservableObject {
    private let configuration: SupportedSettings
    private let componentIx: Int
    private var updating = false

    let settingName: String
    @Published var possibleValues: [Double]
    @Published var currentMin: Double {
        didSet {
            if minAndMaxReversed() {
                updating = true
                currentMax = currentMin
                updating = false
            }
            
            if !updating {
                configuration.includeValues(from: NSNumber(value: currentMin), to: NSNumber(value: currentMax), inComponent: Int32(componentIx))
            }
        }
    }
    @Published var currentMax: Double {
        didSet {
            if minAndMaxReversed() {
                updating = true
                currentMin = currentMax
                updating = false
            }
            
            if !updating {
                configuration.includeValues(from: NSNumber(value: currentMin), to: NSNumber(value: currentMax), inComponent: Int32(componentIx))
            }
        }
    }

    init(configuration: SupportedSettings, componentIx: Int, settingName: String) {
        self.configuration = configuration
        self.componentIx = componentIx
        self.settingName = settingName
        self.possibleValues = allPossibleSettings.components[componentIx].map { $0.doubleValue }
        self.currentMin = configuration.components[componentIx][0].doubleValue
        self.currentMax = configuration.components[componentIx].last!.doubleValue
    }
    
    private func minAndMaxReversed() -> Bool {
        let ascending = componentIx == 0
        
        if ascending {
            return currentMax < currentMin
        } else {
            return currentMax > currentMin
        }
    }
}

let allPossibleSettings = SupportedSettings()!
