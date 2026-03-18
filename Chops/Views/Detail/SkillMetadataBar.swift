import SwiftUI
import SwiftData

struct SkillMetadataBar: View {
    @Bindable var skill: Skill
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Tag.name) private var allTags: [Tag]
    @Query(sort: \SkillCollection.sortOrder) private var allCollections: [SkillCollection]
    @State private var showingTagPicker = false
    @State private var showingCollectionPicker = false

    var body: some View {
        HStack(spacing: 16) {
            // Tool badge
            HStack(spacing: 4) {
                ToolBadge(tool: skill.toolSource, size: .small)
                Text(skill.toolSource.displayName)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Divider().frame(height: 16)

            // File path
            Text(abbreviatedPath)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(1)
                .truncationMode(.middle)
                .help(skill.filePath)

            Divider().frame(height: 16)

            // File size
            Text(formattedSize)
                .font(.caption)
                .foregroundStyle(.secondary)

            Divider().frame(height: 16)

            // Tags
            HStack(spacing: 4) {
                ForEach(skill.tags) { tag in
                    Text(tag.name)
                        .font(.caption2)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color(hex: tag.color)?.opacity(0.2) ?? Color.gray.opacity(0.2), in: Capsule())
                }

                Button {
                    showingTagPicker.toggle()
                } label: {
                    Image(systemName: "tag")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
                .popover(isPresented: $showingTagPicker) {
                    tagPickerContent
                }
            }

            // Collections
            HStack(spacing: 4) {
                Button {
                    showingCollectionPicker.toggle()
                } label: {
                    Image(systemName: "tray")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
                .popover(isPresented: $showingCollectionPicker) {
                    collectionPickerContent
                }
            }

            Spacer()

            // Modified date
            Text(skill.fileModifiedDate.formatted(.relative(presentation: .named)))
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(.bar)
    }

    private var abbreviatedPath: String {
        skill.filePath.replacingOccurrences(
            of: FileManager.default.homeDirectoryForCurrentUser.path,
            with: "~"
        )
    }

    private var formattedSize: String {
        ByteCountFormatter.string(fromByteCount: Int64(skill.fileSize), countStyle: .file)
    }

    private var tagPickerContent: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Tags").font(.headline).padding(.bottom, 4)
            ForEach(allTags) { tag in
                let isAssigned = skill.tags.contains(where: { $0.name == tag.name })
                Button {
                    if isAssigned {
                        skill.tags.removeAll { $0.name == tag.name }
                    } else {
                        skill.tags.append(tag)
                    }
                    try? modelContext.save()
                } label: {
                    HStack {
                        Circle()
                            .fill(Color(hex: tag.color) ?? .gray)
                            .frame(width: 8, height: 8)
                        Text(tag.name)
                        Spacer()
                        if isAssigned {
                            Image(systemName: "checkmark")
                        }
                    }
                }
                .buttonStyle(.plain)
            }
            if allTags.isEmpty {
                Text("No tags yet")
                    .foregroundStyle(.secondary)
                    .font(.caption)
            }
        }
        .padding()
        .frame(width: 200)
    }

    private var collectionPickerContent: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Collections").font(.headline).padding(.bottom, 4)
            ForEach(allCollections) { collection in
                let isAssigned = skill.collections.contains(where: { $0.name == collection.name })
                Button {
                    if isAssigned {
                        skill.collections.removeAll { $0.name == collection.name }
                    } else {
                        skill.collections.append(collection)
                    }
                    try? modelContext.save()
                } label: {
                    HStack {
                        Image(systemName: collection.icon)
                        Text(collection.name)
                        Spacer()
                        if isAssigned {
                            Image(systemName: "checkmark")
                        }
                    }
                }
                .buttonStyle(.plain)
            }
            if allCollections.isEmpty {
                Text("No collections yet")
                    .foregroundStyle(.secondary)
                    .font(.caption)
            }
        }
        .padding()
        .frame(width: 200)
    }
}
