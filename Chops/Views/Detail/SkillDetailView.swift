import SwiftUI
import SwiftData

struct SkillDetailView: View {
    @Bindable var skill: Skill
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        HSplitView {
            // If directory-based, show file browser on the left
            if skill.isDirectory {
                DirectoryBrowserView(skill: skill)
                    .frame(minWidth: 180, maxWidth: 220)
            }

            // Main editor area
            VStack(spacing: 0) {
                SkillEditorView(skill: skill)

                Divider()

                SkillMetadataBar(skill: skill)
            }
        }
        .navigationTitle(skill.name)
        .toolbar {
            ToolbarItem {
                Button {
                    skill.isFavorite.toggle()
                    try? modelContext.save()
                } label: {
                    Image(systemName: skill.isFavorite ? "star.fill" : "star")
                        .foregroundStyle(skill.isFavorite ? .yellow : .secondary)
                }
            }
            ToolbarItem {
                Button {
                    NSWorkspace.shared.selectFile(skill.filePath, inFileViewerRootedAtPath: "")
                } label: {
                    Image(systemName: "folder")
                }
                .help("Show in Finder")
            }
        }
    }
}
