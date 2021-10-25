import SwiftUI

struct ConfigView: View {
    @ObservedObject private var model = ConfigModel(supportedSettings: SupportedSettings())
    
    var body: some View {
        HStack {
            List {
                ForEach(0..<model.pickerModels.count, id: \.self) { i in
                    SettingListItem(settingName: model.pickerModels[i].settingName, isSelected: model.selectedSettingIx == i) {
                        model.selectedSettingIx = i
                    }
                }
            }
            .frame(maxWidth: .infinity)
            
            ValuesPicker(model: $model.selectedModel)
                .frame(maxWidth: .infinity)
        }
    }
}

struct ValuesPicker: View {
    @Binding var model: PickerModel
    
    var body: some View {
        Picker("Label?", selection: .constant("")) {
            ForEach(model.possibleValues, id: \.self) { (option: NSNumber) in
                Text(option.stringValue)
            }
        }
        .pickerStyle(.wheel)
    }
}

class PickerModel: ObservableObject {
    @Published var settingName: String
    @Published var possibleValues: [NSNumber]
    
    init(settingName: String, possibleValues: [NSNumber]) {
        self.settingName = settingName
        self.possibleValues = possibleValues
    }
}

class ConfigModel: ObservableObject {
    let pickerModels: [PickerModel]
    
    @Published var selectedModel: PickerModel
    
    @Published var selectedSettingIx = 0 {
        didSet {
            print("changing selected model based on \(selectedSettingIx)")
            selectedModel = pickerModels[selectedSettingIx]
        }
    }
    
    init(supportedSettings: SupportedSettings) {
        let apertureModel = PickerModel(settingName: "Aperture range", possibleValues: supportedSettings.components[0])
        
        pickerModels = [
            apertureModel,
            PickerModel(settingName: "Shutter range", possibleValues: supportedSettings.components[1]),
            PickerModel(settingName: "ISO range", possibleValues: supportedSettings.components[2]),
        ]
        selectedSettingIx = 0
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
                        .foregroundColor(isSelected ? .white : .black)
                }
                Spacer()
            }
            Spacer()
        }
        .listRowBackground(isSelected ? Color.blue : Color.clear)
    }
}

struct ConfigView_Previews: PreviewProvider {
    static var previews: some View {
        if #available(iOS 15.0, *) {
            ConfigView()
                .previewInterfaceOrientation(.landscapeLeft)
        } else {
            ConfigView()
        }
    }
}
