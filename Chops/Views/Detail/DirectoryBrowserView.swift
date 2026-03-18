import SwiftUI

struct DirectoryBrowserView: View {
    let skill: Skill
    @State private var files: [FileItem] = []
    @State private var selectedFile: FileItem?

    struct FileItem: Identifiable, Hashable {
        let id = UUID()
        let name: String
        let path: String
        let isDirectory: Bool
        let children: [FileItem]
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Files")
                .font(.caption)
                .foregroundStyle(.secondary)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)

            Divider()

            List(files, children: \.optionalChildren) { item in
                HStack(spacing: 6) {
                    Image(systemName: item.isDirectory ? "folder.fill" : fileIcon(for: item.name))
                        .font(.caption)
                        .foregroundStyle(item.isDirectory ? .blue : .secondary)
                    Text(item.name)
                        .font(.caption)
                        .lineLimit(1)
                }
                .tag(item)
            }
            .listStyle(.sidebar)
        }
        .onAppear {
            loadFiles()
        }
    }

    private func loadFiles() {
        let skillDir = URL(fileURLWithPath: skill.filePath).deletingLastPathComponent()
        files = scanDirectory(skillDir)
    }

    private func scanDirectory(_ url: URL) -> [FileItem] {
        let fm = FileManager.default
        guard let contents = try? fm.contentsOfDirectory(
            at: url,
            includingPropertiesForKeys: [.isDirectoryKey],
            options: [.skipsHiddenFiles]
        ) else { return [] }

        return contents.sorted { $0.lastPathComponent < $1.lastPathComponent }.map { item in
            var isDir: ObjCBool = false
            fm.fileExists(atPath: item.path, isDirectory: &isDir)
            let children = isDir.boolValue ? scanDirectory(item) : []
            return FileItem(
                name: item.lastPathComponent,
                path: item.path,
                isDirectory: isDir.boolValue,
                children: children
            )
        }
    }

    private func fileIcon(for name: String) -> String {
        let ext = (name as NSString).pathExtension.lowercased()
        switch ext {
        case "md", "markdown": return "doc.text"
        case "yml", "yaml": return "doc.badge.gearshape"
        case "json": return "curlybraces"
        case "swift": return "swift"
        case "py": return "chevron.left.forwardslash.chevron.right"
        case "sh", "bash", "zsh": return "terminal"
        default: return "doc"
        }
    }
}

extension DirectoryBrowserView.FileItem {
    var optionalChildren: [DirectoryBrowserView.FileItem]? {
        isDirectory ? children : nil
    }
}
