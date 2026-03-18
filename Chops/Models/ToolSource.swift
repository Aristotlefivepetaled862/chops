import SwiftUI

enum ToolSource: String, Codable, CaseIterable, Identifiable {
    case claude
    case cursor
    case windsurf
    case codex
    case copilot
    case aider
    case amp
    case custom

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .claude: "Claude Code"
        case .cursor: "Cursor"
        case .windsurf: "Windsurf"
        case .codex: "Codex"
        case .copilot: "Copilot"
        case .aider: "Aider"
        case .amp: "Amp"
        case .custom: "Custom"
        }
    }

    var iconName: String {
        switch self {
        case .claude: "brain.head.profile"
        case .cursor: "cursorarrow.rays"
        case .windsurf: "wind"
        case .codex: "book.closed"
        case .copilot: "airplane"
        case .aider: "wrench.and.screwdriver"
        case .amp: "bolt.fill"
        case .custom: "folder"
        }
    }

    var color: Color {
        switch self {
        case .claude: .orange
        case .cursor: .blue
        case .windsurf: .teal
        case .codex: .green
        case .copilot: .purple
        case .aider: .yellow
        case .amp: .pink
        case .custom: .gray
        }
    }

    var globalPaths: [String] {
        let home = FileManager.default.homeDirectoryForCurrentUser.path
        switch self {
        case .claude: return ["\(home)/.claude/skills", "\(home)/.agents/skills"]
        case .cursor: return ["\(home)/.cursor/skills", "\(home)/.cursor/rules"]
        case .windsurf: return ["\(home)/.codeium/windsurf/memories", "\(home)/.windsurf/rules"]
        case .codex: return ["\(home)/.codex"]
        case .copilot: return []
        case .aider: return []
        case .amp: return ["\(home)/.config/amp"]
        case .custom: return []
        }
    }
}
