import SwiftUI

struct HabitRowView: View {
    let habit: Habit
    let isCompleted: Bool
    let streak: Int
    let onToggle: () -> Void

    private var habitColor: Color {
        Color(hex: habit.colorHex) ?? .indigo
    }

    var body: some View {
        HStack(spacing: 14) {

            // Botón circular de completado
            Button(action: onToggle) {
                ZStack {
                    Circle()
                        .strokeBorder(habitColor, lineWidth: 2)
                        .frame(width: 28, height: 28)

                    if isCompleted {
                        Circle()
                            .fill(habitColor)
                            .frame(width: 28, height: 28)

                        Image(systemName: "checkmark")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(.white)
                    }
                }
            }
            .buttonStyle(.plain)
            .animation(.spring(duration: 0.25), value: isCompleted)

            // Nombre del hábito
            VStack(alignment: .leading, spacing: 2) {
                Text(habit.name)
                    .font(.body)
                    .foregroundStyle(isCompleted ? .secondary : .primary)
                    .strikethrough(isCompleted, color: .secondary)
            }

            Spacer()

            StreakBadge(streak: streak)
        }
        .padding(.vertical, 4)
    }
}
