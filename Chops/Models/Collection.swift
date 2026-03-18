import SwiftData
import Foundation

@Model
final class SkillCollection {
    @Attribute(.unique) var name: String
    var icon: String
    var sortOrder: Int

    @Relationship(inverse: \Skill.collections)
    var skills: [Skill]

    init(name: String, icon: String = "folder", skills: [Skill] = [], sortOrder: Int = 0) {
        self.name = name
        self.icon = icon
        self.skills = skills
        self.sortOrder = sortOrder
    }
}
