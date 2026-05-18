import SwiftUI

struct StreakBadge: View {
    let streak: Int

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "flame.fill")
                .font(.caption)
            Text("\(streak)")
                .font(.caption)
                .fontWeight(.semibold)
        }
        .foregroundStyle(streak > 0 ? .orange : .secondary)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(
            Capsule()
                .fill(streak > 0
                      ? Color.orange.opacity(0.15)
                      : Color.secondary.opacity(0.1))
        )
    }
}
