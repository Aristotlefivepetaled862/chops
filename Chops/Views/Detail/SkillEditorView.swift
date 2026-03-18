import SwiftUI

struct SkillEditorView: View {
    @Bindable var skill: Skill
    @State private var editorContent: String = ""
    @State private var hasUnsavedChanges = false
    @State private var showingSaveError = false
    @State private var saveErrorMessage = ""

    var body: some View {
        ZStack(alignment: .topTrailing) {
            TextEditor(text: $editorContent)
                .font(.system(.body, design: .monospaced))
                .scrollContentBackground(.hidden)
                .padding(8)

            if hasUnsavedChanges {
                Text("Modified")
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(.orange.opacity(0.2), in: Capsule())
                    .foregroundStyle(.orange)
                    .padding(12)
            }
        }
        .onChange(of: editorContent) {
            hasUnsavedChanges = editorContent != fullFileContent
        }
        .onAppear {
            loadContent()
        }
        .onChange(of: skill.filePath) {
            loadContent()
        }
        .focusedValue(\.saveAction, SaveAction(action: saveFile))
        .alert("Save Error", isPresented: $showingSaveError) {
            Button("OK") {}
        } message: {
            Text(saveErrorMessage)
        }
    }

    @State private var fullFileContent: String = ""

    private func loadContent() {
        if let data = try? String(contentsOfFile: skill.filePath, encoding: .utf8) {
            editorContent = data
            fullFileContent = data
        } else {
            editorContent = skill.content
            fullFileContent = skill.content
        }
        hasUnsavedChanges = false
    }

    private func saveFile() {
        do {
            try editorContent.write(toFile: skill.filePath, atomically: true, encoding: .utf8)
            fullFileContent = editorContent
            hasUnsavedChanges = false

            let parsed = FrontmatterParser.parse(editorContent)
            if !parsed.name.isEmpty {
                skill.name = parsed.name
            }
            skill.skillDescription = parsed.description
            skill.content = parsed.content
            skill.frontmatter = parsed.frontmatter
        } catch {
            saveErrorMessage = error.localizedDescription
            showingSaveError = true
        }
    }
}

// MARK: - Save Action via FocusedValues for Cmd+S menu support

struct SaveAction {
    let action: () -> Void
}

struct SaveActionKey: FocusedValueKey {
    typealias Value = SaveAction
}

extension FocusedValues {
    var saveAction: SaveAction? {
        get { self[SaveActionKey.self] }
        set { self[SaveActionKey.self] = newValue }
    }
}
