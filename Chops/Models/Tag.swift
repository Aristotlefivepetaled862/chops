import SwiftData
import Foundation

@Model
final class Tag {
    @Attribute(.unique) var name: String
    var color: String

    @Relationship(inverse: \Skill.tags)
    var skills: [Skill]

    init(name: String, color: String = "#808080", skills: [Skill] = []) {
        self.name = name
        self.color = color
        self.skills = skills
    }
}
