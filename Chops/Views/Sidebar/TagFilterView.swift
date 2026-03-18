import SwiftUI
import SwiftData

struct TagFilterView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Tag.name) private var tags: [Tag]
    @State private var showingNewTag = false
    @State private var newTagName = ""
    @State private var newTagColor = Color.blue

    var body: some View {
        ForEach(tags) { tag in
            Button {
                if appState.sidebarFilter == .tag(tag.name) {
                    appState.sidebarFilter = .all
                } else {
                    appState.sidebarFilter = .tag(tag.name)
                }
            } label: {
                Label {
                    HStack {
                        Text(tag.name)
                        Spacer()
                        Text("\(tag.skills.count)")
                            .foregroundStyle(.secondary)
                            .font(.caption)
                    }
                } icon: {
                    Circle()
                        .fill(Color(hex: tag.color) ?? .gray)
                        .frame(width: 10, height: 10)
                }
            }
            .buttonStyle(.plain)
            .fontWeight(appState.sidebarFilter == .tag(tag.name) ? .semibold : .regular)
            .contextMenu {
                Button("Delete", role: .destructive) {
                    modelContext.delete(tag)
                    try? modelContext.save()
                    if appState.sidebarFilter == .tag(tag.name) {
                        appState.sidebarFilter = .all
                    }
                }
            }
        }

        Button {
            showingNewTag = true
        } label: {
            Label("New Tag", systemImage: "plus.circle")
                .foregroundStyle(.secondary)
        }
        .buttonStyle(.plain)
        .popover(isPresented: $showingNewTag) {
            VStack(spacing: 12) {
                TextField("Tag name", text: $newTagName)
                    .textFieldStyle(.roundedBorder)
                ColorPicker("Color", selection: $newTagColor)
                HStack {
                    Button("Cancel") { showingNewTag = false }
                    Spacer()
                    Button("Create") {
                        let tag = Tag(name: newTagName, color: newTagColor.hexString)
                        modelContext.insert(tag)
                        try? modelContext.save()
                        newTagName = ""
                        showingNewTag = false
                    }
                    .disabled(newTagName.isEmpty)
                }
            }
            .padding()
            .frame(width: 220)
        }
    }
}

// MARK: - Color Hex Helpers

extension Color {
    init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        guard hexSanitized.count == 6 else { return nil }

        var rgb: UInt64 = 0
        Scanner(string: hexSanitized).scanHexInt64(&rgb)

        self.init(
            red: Double((rgb & 0xFF0000) >> 16) / 255.0,
            green: Double((rgb & 0x00FF00) >> 8) / 255.0,
            blue: Double(rgb & 0x0000FF) / 255.0
        )
    }

    var hexString: String {
        guard let components = NSColor(self).cgColor.components, components.count >= 3 else {
            return "#808080"
        }
        let r = Int(components[0] * 255)
        let g = Int(components[1] * 255)
        let b = Int(components[2] * 255)
        return String(format: "#%02X%02X%02X", r, g, b)
    }
}
