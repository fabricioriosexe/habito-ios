import SwiftUI

struct HabitRowView: View {
    let habit: Habit
    let isCompleted: Bool
    let streak: Int
    let onToggle: () -> Void  // Closure = función que la vista padre nos pasa

    private var habitColor: Color {
        Color(hex: habit.colorHex) ?? .indigo  // ?? = "si falla, usá índigo"
    }

    var body: some View {
        HStack(spacing: 14) {

            Button(action: onToggle) {
                ZStack {  // ZStack apila vistas una encima de otra
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
            .buttonStyle(.plain)  // Evita que el tap active toda la fila del List
            // value: isCompleted = "animá cuando este valor cambie"
            .animation(.spring(duration: 0.25), value: isCompleted)

            Text(habit.name)
                .font(.body)
                .foregroundStyle(isCompleted ? .secondary : .primary)
                .strikethrough(isCompleted, color: .secondary)

            Spacer()  // Empuja el badge hacia la derecha

            StreakBadge(streak: streak)
        }
        .padding(.vertical, 4)
    }
}
