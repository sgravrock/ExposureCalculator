import SwiftUI

struct ConfigView: View {
    private let settingNames = ["Aperture range", "Shutter range", "ISO range"]
    @State private var selectedSettingName = "Aperture range"
    
    var body: some View {
        HStack {
            List {
                ForEach(settingNames, id: \.self) { name in
                    SettingListItem(settingName: name, isSelected: selectedSettingName == name) {
                        selectedSettingName = name
                    }
                }
            }
            .frame(maxWidth: .infinity)
            Text(selectedSettingName)
                .frame(maxWidth: .infinity)

        }
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
