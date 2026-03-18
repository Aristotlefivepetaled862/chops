import SwiftUI

struct ToolBadge: View {
    let tool: ToolSource
    var size: BadgeSize = .regular

    enum BadgeSize {
        case small, regular, large

        var iconFont: Font {
            switch self {
            case .small: .caption2
            case .regular: .caption
            case .large: .body
            }
        }

        var padding: CGFloat {
            switch self {
            case .small: 3
            case .regular: 4
            case .large: 6
            }
        }
    }

    var body: some View {
        Image(systemName: tool.iconName)
            .font(size.iconFont)
            .foregroundStyle(.white)
            .padding(size.padding)
            .background(tool.color, in: RoundedRectangle(cornerRadius: 4))
    }
}
