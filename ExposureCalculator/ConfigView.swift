import SwiftUI
import Combine

let bgColor = Color(red: 0.33, green: 0.33, blue: 0.33)
let settingItemBgColor = Color.clear
let selectedSettingItemBgColor = Color(red: 0.82, green: 0.82, blue: 0.84)


struct ConfigView: View {
    @ObservedObject private var model: ConfigViewModel
    
    init(configuration: SupportedSettings) {
        model = ConfigViewModel(configuration: configuration)
        // Wheee
        UITableView.appearance().backgroundColor = .clear
        UITableView.appearance().separatorStyle = .none
    }
    
    var body: some View {
        HStack {
            List {
                ForEach(0..<model.pickerModels.count, id: \.self) { i in
                    SettingListItem(settingName: model.pickerModels[i].settingName, isSelected: model.selectedComponentIx == i) {
                        model.selectedComponentIx = i
                    }
                }
            }
            .frame(maxWidth: .infinity)
            
            HStack {
                VStack {
                    Text("From")
                        .foregroundColor(.white)
                    ValuesPicker(model: $model.selectedModel, componentIx: $model.selectedComponentIx, selectedValue: $model.selectedModel.currentMin)
                        .frame(maxWidth: .infinity)
                }
                VStack {
                    Text("To")
                        .foregroundColor(.white)
                    ValuesPicker(model: $model.selectedModel, componentIx: $model.selectedComponentIx, selectedValue: $model.selectedModel.currentMax)
                        .frame(maxWidth: .infinity)
                }
            }
            .frame(maxWidth: .infinity)

        }
        .background(bgColor)
    }
}


struct ValuesPicker: View {
    @Binding var model: PickerViewModel
    @Binding var componentIx: Int
    @Binding var selectedValue: Double
    
    var body: some View {
        Picker("Label?", selection: $selectedValue) {
            ForEach(model.possibleValues, id: \.self) { (option: Double) in
                Text(Setting.formatSetting(withComponent: UInt(componentIx), value: NSNumber(value: option)))
                    .foregroundColor(.white)
            }
        }
        .pickerStyle(.wheel)
        // TODO: Is there a way to prevent pickers from expanding to 320px without setting a fixed width? The usual .frame(maxWidth: .infinity) tricks don't work.
        // n.b. we can only get away with using the screen size here because we only run in one orientation, don't support side by side on iPads, etc. Don't try this turrible hack at home.
        .frame(maxWidth: UIScreen.main.bounds.size.width / 4 - 20)
        .compositingGroup() // (╯°□°)╯︵ ┻━┻
        .clipped()
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

struct SettingListItem: View {
    var settingName: String
    var isSelected: Bool
    var action: () -> Void
    
    var body: some View {
        HStack {
            VStack {
                Button(action: action) {
                    Text(settingName)
                        .foregroundColor(isSelected ? .black : .white)
                }
                Spacer()
            }
            Spacer()
        }
        .listRowBackground(bgColor())
    }
    
    private func bgColor() -> Color {
        if isSelected {
            return selectedSettingItemBgColor
        } else {
            return settingItemBgColor
        }
    }
}

struct ConfigView_Previews: PreviewProvider {
    static var previews: some View {
        if #available(iOS 15.0, *) {
            ConfigView(configuration: SupportedSettings())
                .previewInterfaceOrientation(.landscapeLeft)
        } else {
            ConfigView(configuration: SupportedSettings())
        }
    }
}
