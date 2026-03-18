import Foundation
import SwiftData

@Observable
final class SkillScanner {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func scanAll() {
        for tool in ToolSource.allCases where tool != .custom {
            scanTool(tool)
        }
        let customPaths = UserDefaults.standard.stringArray(forKey: "customScanPaths") ?? []
        for path in customPaths {
            scanDirectory(URL(fileURLWithPath: path), toolSource: .custom)
        }
    }

    func scanTool(_ tool: ToolSource) {
        for path in tool.globalPaths {
            let url = URL(fileURLWithPath: path)
            scanDirectory(url, toolSource: tool)
        }
    }

    private func scanDirectory(_ directory: URL, toolSource: ToolSource) {
        let fm = FileManager.default

        var isDir: ObjCBool = false
        guard fm.fileExists(atPath: directory.path, isDirectory: &isDir) else { return }

        // Single-file tools like Codex: look for AGENTS.md directly in the directory
        if toolSource == .codex || toolSource == .amp {
            let agentsMD = directory.appendingPathComponent("AGENTS.md")
            if fm.fileExists(atPath: agentsMD.path) {
                upsertSkill(at: agentsMD, toolSource: toolSource, isDirectory: false)
            }
            // Also scan subdirectories for skills
            if let contents = try? fm.contentsOfDirectory(
                at: directory,
                includingPropertiesForKeys: [.isDirectoryKey],
                options: [.skipsHiddenFiles]
            ) {
                for item in contents {
                    var itemIsDir: ObjCBool = false
                    fm.fileExists(atPath: item.path, isDirectory: &itemIsDir)
                    if itemIsDir.boolValue {
                        let skillFile = item.appendingPathComponent("AGENTS.md")
                        if fm.fileExists(atPath: skillFile.path) {
                            upsertSkill(at: skillFile, toolSource: toolSource, isDirectory: true)
                        }
                    }
                }
            }
            return
        }

        guard isDir.boolValue else { return }

        guard let contents = try? fm.contentsOfDirectory(
            at: directory,
            includingPropertiesForKeys: [.isDirectoryKey, .isSymbolicLinkKey, .contentModificationDateKey, .fileSizeKey],
            options: [.skipsHiddenFiles]
        ) else { return }

        for item in contents {
            var itemIsDir: ObjCBool = false
            fm.fileExists(atPath: item.path, isDirectory: &itemIsDir)

            if itemIsDir.boolValue {
                // Directory-based skill — look for SKILL.md or AGENTS.md inside
                let skillFile = item.appendingPathComponent("SKILL.md")
                let agentsFile = item.appendingPathComponent("AGENTS.md")

                if fm.fileExists(atPath: skillFile.path) {
                    upsertSkill(at: skillFile, toolSource: toolSource, isDirectory: true)
                } else if fm.fileExists(atPath: agentsFile.path) {
                    upsertSkill(at: agentsFile, toolSource: toolSource, isDirectory: true)
                }
            } else if item.pathExtension == "md" || item.pathExtension == "mdc" {
                upsertSkill(at: item, toolSource: toolSource, isDirectory: false)
            }
        }
    }

    private func upsertSkill(at fileURL: URL, toolSource: ToolSource, isDirectory: Bool) {
        let fm = FileManager.default
        let path = fileURL.path
        let resolvedPath = fileURL.resolvingSymlinksInPath().path

        guard let parsed = SkillParser.parse(fileURL: fileURL, toolSource: toolSource) else { return }

        let attrs = try? fm.attributesOfItem(atPath: resolvedPath)
        let modDate = (attrs?[.modificationDate] as? Date) ?? .now
        let fileSize = (attrs?[.size] as? Int) ?? 0

        let name: String
        if !parsed.name.isEmpty {
            name = parsed.name
        } else if isDirectory {
            name = fileURL.deletingLastPathComponent().lastPathComponent
        } else {
            name = fileURL.deletingPathExtension().lastPathComponent
        }

        let predicate = #Predicate<Skill> { $0.filePath == path }
        let descriptor = FetchDescriptor<Skill>(predicate: predicate)

        if let existing = try? modelContext.fetch(descriptor).first {
            existing.content = parsed.content
            existing.name = name
            existing.skillDescription = parsed.description
            existing.frontmatter = parsed.frontmatter
            existing.fileModifiedDate = modDate
            existing.fileSize = fileSize
            existing.resolvedPath = resolvedPath
        } else {
            let skill = Skill(
                filePath: path,
                toolSource: toolSource,
                isDirectory: isDirectory,
                name: name,
                skillDescription: parsed.description,
                content: parsed.content,
                frontmatter: parsed.frontmatter,
                fileModifiedDate: modDate,
                fileSize: fileSize,
                isGlobal: true,
                resolvedPath: resolvedPath
            )
            modelContext.insert(skill)
        }

        try? modelContext.save()
    }

    func removeDeletedSkills() {
        let descriptor = FetchDescriptor<Skill>()
        guard let skills = try? modelContext.fetch(descriptor) else { return }
        let fm = FileManager.default

        for skill in skills {
            if !fm.fileExists(atPath: skill.filePath) {
                modelContext.delete(skill)
            }
        }
        try? modelContext.save()
    }
}
