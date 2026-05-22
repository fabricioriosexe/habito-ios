import Foundation
import SwiftData
import Observation  // El framework que hace funcionar @Observable

// @Observable reemplaza al viejo ObservableObject.
// Le dice a SwiftUI: "vigilá esta clase, cuando
// algo cambie, actualizá las vistas automáticamente"
@Observable
final class HabitViewModel {

    // ModelContext = el "cuaderno de operaciones" de SwiftData.
    // Le decís "insertá esto", "borrá esto" y él habla con el disco.
    // Es "private" porque NADIE fuera del ViewModel debe tocarlo.
    private var modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    // MARK: - Hábitos

    func addHabit(name: String, colorHex: String) {
        guard !name.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        // "insert" = agregar a la base de datos
        modelContext.insert(Habit(name: name, colorHex: colorHex))
        save()
    }

    func deleteHabits(_ habits: [Habit], at offsets: IndexSet) {
        // IndexSet = conjunto de posiciones en la lista
        // (SwiftUI nos lo da cuando el usuario hace swipe)
        for index in offsets { modelContext.delete(habits[index]) }
        save()
    }

    // MARK: - Lógica del hábito

    func isCompletedToday(_ habit: Habit) -> Bool {
        // contains + closure: "¿alguna fecha en el array cumple esta condición?"
        habit.completedDates.contains { $0.isSameDay(as: Date()) }
    }

    func toggleToday(_ habit: Habit) {
        if isCompletedToday(habit) {
            // removeAll con condición: saca los que cumplan el filtro
            habit.completedDates.removeAll { $0.isSameDay(as: Date()) }
        } else {
            habit.completedDates.append(Date())
        }
        save()
    }

    func currentStreak(for habit: Habit) -> Int {
        let calendar = Calendar.current

        // Set elimina duplicados — si el usuario marcó y desmarcó
        // varias veces el mismo día, solo cuenta una vez
        let days = Set(habit.completedDates.map { $0.startOfDay })
            .sorted(by: >)  // ordenados del más reciente al más antiguo

        guard !days.isEmpty else { return 0 }

        var streak = 0
        var check = Date().startOfDay  // Empezamos desde hoy

        for day in days {
            if day == check {
                streak += 1
                // Retrocedemos un día y seguimos buscando
                check = calendar.date(byAdding: .day, value: -1, to: check)!
            } else {
                break  // Hueco encontrado — racha rota
            }
        }
        return streak
    }

    // MARK: - Fuego del día

    func allCompletedToday(_ habits: [Habit]) -> Bool {
        guard !habits.isEmpty else { return false }
        // allSatisfy: true solo si TODOS cumplen la condición
        return habits.allSatisfy { isCompletedToday($0) }
    }

    func completedCount(on date: Date, habits: [Habit]) -> Int {
        habits.filter { habit in
            habit.completedDates.contains { $0.isSameDay(as: date) }
        }.count
    }

    // MARK: - Calendario

    // Devuelve un número de 0.0 a 1.0
    // 0.0 = no completó nada ese día
    // 1.0 = completó todos los hábitos ese día
    func intensity(on date: Date, habits: [Habit]) -> Double {
        guard !habits.isEmpty else { return 0 }
        let count = completedCount(on: date, habits: habits)
        return Double(count) / Double(habits.count)
    }

    func monthCompletionRate(habits: [Habit]) -> Int {
        let calendar = Calendar.current
        let now = Date()
        guard let monthStart = calendar.date(
            from: calendar.dateComponents([.year, .month], from: now)
        ) else { return 0 }

        let passedDays = calendar.component(.day, from: now)
        guard passedDays > 0, !habits.isEmpty else { return 0 }

        var totalCompleted = 0
        for dayOffset in 0..<passedDays {
            if let day = calendar.date(byAdding: .day, value: dayOffset, to: monthStart) {
                totalCompleted += completedCount(on: day, habits: habits)
            }
        }
        let maxPossible = passedDays * habits.count
        return maxPossible > 0 ? Int(Double(totalCompleted) / Double(maxPossible) * 100) : 0
    }

    func bestStreak(habits: [Habit]) -> Int {
        // map transforma cada hábito en su racha
        // max() devuelve el mayor, ?? 0 si está vacío
        habits.map { currentStreak(for: $0) }.max() ?? 0
    }

    // MARK: - Guardar

    private func save() {
        // try? = intentalo y si falla, no crashees
        try? modelContext.save()
    }
}
