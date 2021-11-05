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
    @Published var settingName: String
    @Published var possibleValues: [Double]
    private let ascending: Bool
    @Published var currentMin: Double {
        didSet {
            // TODO rework this to use the model's logic
            if (ascending && currentMax < currentMin) || (!ascending && currentMax > currentMin) {
                currentMax = currentMin
            }
        }
    }
    @Published var currentMax: Double {
        didSet {
            // TODO rework this to use the model's logic
            if (ascending && currentMax < currentMin) || (!ascending && currentMax > currentMin) {
                print("clamping currentMin to \(currentMax)")
                currentMin = currentMax
            }
        }
    }

    init(settingName: String, possibleValues: [NSNumber], ascending: Bool, currentMin: NSNumber, currentMax: NSNumber) {
        self.settingName = settingName
        self.possibleValues = possibleValues.map { $0.doubleValue }
        self.ascending = ascending
        self.currentMin = currentMin.doubleValue
        self.currentMax = currentMax.doubleValue
    }
}

class ConfigViewModel: ObservableObject {
    let pickerModels: [PickerViewModel]
    private var retainObservers: [AnyCancellable] = []
    
    @Published var selectedModel: PickerViewModel
    
    @Published var selectedComponentIx = 0 {
        didSet {
            selectedModel = pickerModels[selectedComponentIx]
        }
    }
    
    init(configuration: SupportedSettings) {
        let allPossibleSettings = SupportedSettings()!
        let apertureModel = PickerViewModel(settingName: "Aperture range", possibleValues: allPossibleSettings.apertures(), ascending: true, currentMin: configuration.minAperture(), currentMax: configuration.maxAperture())
        let shutterModel = PickerViewModel(settingName: "Shutter range", possibleValues: allPossibleSettings.shutterSpeeds(), ascending: false, currentMin: configuration.minShutterSpeed(), currentMax: configuration.maxShutterSpeed())
        let isoModel = PickerViewModel(settingName: "ISO range", possibleValues: allPossibleSettings.isos(), ascending: false, currentMin: configuration.minIso(), currentMax: configuration.maxIso())

        pickerModels = [apertureModel, shutterModel, isoModel]
        selectedComponentIx = 0
        selectedModel = apertureModel
        
        retainObservers.append(apertureModel.$currentMin.sink { [weak self] newValue in
            print("min aperture observer called with \(newValue)")
            if newValue != configuration.minAperture().doubleValue {
                configuration.includeValues(from: NSNumber(value: newValue), to: configuration.maxAperture(), inComponent: 0)
            }
        })
        retainObservers.append(apertureModel.$currentMax.sink { [weak self] newValue in
            print("max aperture observer called with \(newValue)")
            if newValue != configuration.maxAperture().doubleValue {
                configuration.includeValues(from: configuration.minAperture(), to: NSNumber(value: newValue), inComponent: 0)
            }
        })
        retainObservers.append(shutterModel.$currentMin.sink { [weak self] newValue in
            if newValue != configuration.minShutterSpeed().doubleValue {
                configuration.includeValues(from: NSNumber(value: newValue), to: configuration.maxShutterSpeed(), inComponent: 1)
            }
        })
        retainObservers.append(shutterModel.$currentMax.sink { [weak self] newValue in
            if newValue != configuration.maxShutterSpeed().doubleValue {
                configuration.includeValues(from: configuration.minShutterSpeed(), to: NSNumber(value: newValue), inComponent: 1)
            }
        })
        retainObservers.append(isoModel.$currentMin.sink { [weak self] newValue in
            if newValue != configuration.minIso().doubleValue {
                configuration.includeValues(from: NSNumber(value: newValue), to: configuration.maxIso(), inComponent: 2)
            }
        })
        retainObservers.append(isoModel.$currentMax.sink { [weak self] newValue in
            if newValue != configuration.maxIso().doubleValue {
                configuration.includeValues(from: configuration.minIso(), to: NSNumber(value: newValue), inComponent: 2)
            }
        })
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
