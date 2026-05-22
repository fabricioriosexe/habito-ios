import SwiftUI

struct StreakBadge: View {
    let streak: Int
    private let maxVisible = 5  // Máximo de llamas antes de mostrar número

    var body: some View {
        HStack(spacing: 1) {
            if streak == 0 {
                Text("0 🔥")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            } else {
                let visible = min(streak, maxVisible)
                // String(repeating:count:) genera "🔥🔥🔥" dinámicamente
                Text(String(repeating: "🔥", count: visible))
                    .font(.caption)

                if streak > maxVisible {
                    Text("×\(streak)")
                        .font(.caption2)
                        .fontWeight(.semibold)
                        .foregroundStyle(.orange)
                }
            }
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 3)
        .background(
            Capsule().fill(streak > 0 ? Color.orange.opacity(0.12) : Color.clear)
        )
    }
}
