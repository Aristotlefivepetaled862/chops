import SwiftUI
import SwiftData

struct SidebarView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(AppState.self) private var appState
    @Query(sort: \Skill.name) private var allSkills: [Skill]
    @Query(sort: \Tag.name) private var tags: [Tag]
    @Query(sort: \SkillCollection.sortOrder) private var collections: [SkillCollection]

    private var filteredSkills: [Skill] {
        var result = allSkills

        switch appState.sidebarFilter {
        case .all:
            break
        case .favorites:
            result = result.filter { $0.isFavorite }
        case .tool(let tool):
            result = result.filter { $0.toolSource == tool }
        case .tag(let tagName):
            result = result.filter { skill in
                skill.tags.contains { $0.name == tagName }
            }
        case .collection(let collName):
            result = result.filter { skill in
                skill.collections.contains { $0.name == collName }
            }
        }

        if !appState.searchText.isEmpty {
            result = result.filter {
                $0.name.localizedCaseInsensitiveContains(appState.searchText) ||
                $0.skillDescription.localizedCaseInsensitiveContains(appState.searchText) ||
                $0.content.localizedCaseInsensitiveContains(appState.searchText)
            }
        }

        return result
    }

    var body: some View {
        @Bindable var appState = appState

        List(selection: $appState.selectedSkill) {
            // Filter sections
            Section("Library") {
                SidebarFilterRow(label: "All Skills", icon: "tray.full", filter: .all, count: allSkills.count)
                SidebarFilterRow(label: "Favorites", icon: "star.fill", filter: .favorites, count: allSkills.filter(\.isFavorite).count)
            }

            Section("Tools") {
                ToolFilterView()
            }

            if !tags.isEmpty {
                Section("Tags") {
                    TagFilterView()
                }
            }

            if !collections.isEmpty {
                Section("Collections") {
                    CollectionListView()
                }
            }

            Section("Skills") {
                ForEach(filteredSkills) { skill in
                    SkillRow(skill: skill)
                        .tag(skill)
                        .contextMenu {
                            Button(skill.isFavorite ? "Unfavorite" : "Favorite") {
                                skill.isFavorite.toggle()
                                try? modelContext.save()
                            }
                            Divider()
                            Button("Show in Finder") {
                                NSWorkspace.shared.selectFile(skill.filePath, inFileViewerRootedAtPath: "")
                            }
                        }
                }
            }
        }
        .listStyle(.sidebar)
        .navigationTitle("Chops")
    }
}

struct SidebarFilterRow: View {
    @Environment(AppState.self) private var appState
    let label: String
    let icon: String
    let filter: SidebarFilter
    let count: Int

    var body: some View {
        Button {
            appState.sidebarFilter = filter
        } label: {
            Label {
                HStack {
                    Text(label)
                    Spacer()
                    Text("\(count)")
                        .foregroundStyle(.secondary)
                        .font(.caption)
                }
            } icon: {
                Image(systemName: icon)
            }
        }
        .buttonStyle(.plain)
        .fontWeight(appState.sidebarFilter == filter ? .semibold : .regular)
    }
}

struct SkillRow: View {
    let skill: Skill

    var body: some View {
        HStack(spacing: 8) {
            ToolBadge(tool: skill.toolSource, size: .small)

            VStack(alignment: .leading, spacing: 2) {
                Text(skill.name)
                    .fontWeight(.medium)
                    .lineLimit(1)

                if !skill.skillDescription.isEmpty {
                    Text(skill.skillDescription)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }

            Spacer()

            if skill.isFavorite {
                Image(systemName: "star.fill")
                    .font(.caption)
                    .foregroundStyle(.yellow)
            }
        }
        .padding(.vertical, 2)
    }
}
