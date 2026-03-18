import SwiftData
import Foundation

@Model
final class Skill {
    @Attribute(.unique) var filePath: String
    var toolSourceRaw: String
    var isDirectory: Bool
    var name: String
    var skillDescription: String
    var content: String
    var frontmatterData: Data?
    var tags: [Tag]
    var collections: [SkillCollection]
    var isFavorite: Bool
    var lastOpened: Date?
    var fileModifiedDate: Date
    var fileSize: Int
    var isGlobal: Bool
    var resolvedPath: String

    var toolSource: ToolSource {
        get { ToolSource(rawValue: toolSourceRaw) ?? .custom }
        set { toolSourceRaw = newValue.rawValue }
    }

    var frontmatter: [String: String] {
        get {
            guard let data = frontmatterData else { return [:] }
            return (try? JSONDecoder().decode([String: String].self, from: data)) ?? [:]
        }
        set {
            frontmatterData = try? JSONEncoder().encode(newValue)
        }
    }

    init(
        filePath: String,
        toolSource: ToolSource,
        isDirectory: Bool = false,
        name: String = "",
        skillDescription: String = "",
        content: String = "",
        frontmatter: [String: String] = [:],
        tags: [Tag] = [],
        collections: [SkillCollection] = [],
        isFavorite: Bool = false,
        lastOpened: Date? = nil,
        fileModifiedDate: Date = .now,
        fileSize: Int = 0,
        isGlobal: Bool = true,
        resolvedPath: String = ""
    ) {
        self.filePath = filePath
        self.toolSourceRaw = toolSource.rawValue
        self.isDirectory = isDirectory
        self.name = name
        self.skillDescription = skillDescription
        self.content = content
        self.frontmatterData = try? JSONEncoder().encode(frontmatter)
        self.tags = tags
        self.collections = collections
        self.isFavorite = isFavorite
        self.lastOpened = lastOpened
        self.fileModifiedDate = fileModifiedDate
        self.fileSize = fileSize
        self.isGlobal = isGlobal
        self.resolvedPath = resolvedPath
    }
}
