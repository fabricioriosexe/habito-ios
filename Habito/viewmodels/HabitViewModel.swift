import Foundation
import SwiftData
import Observation

@Observable
final class HabitViewModel {
    
    // El ModelContext es el "lápiz" con el que escribimos
    // y borramos datos en SwiftData.
    private var modelContext: ModelContext
    
    // MARK: - Inicialización
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    // MARK: - Operaciones CRUD
    
    /// Crea un nuevo hábito y lo guarda en la base de datos.
    func addHabit(name: String, colorHex: String) {
        guard !name.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        let newHabit = Habit(name: name, colorHex: colorHex)
        modelContext.insert(newHabit)
        save()
    }
    
    /// Elimina uno o varios hábitos de un IndexSet (para el swipe-to-delete).
    func deleteHabits(_ habits: [Habit], at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(habits[index])
        }
        save()
    }
    
    // MARK: - Lógica del Hábito
    
    /// Verifica si un hábito fue completado HOY.
    func isCompletedToday(_ habit: Habit) -> Bool {
        habit.completedDates.contains { $0.isSameDay(as: Date()) }
    }
    
    /// Alterna el estado de completado para HOY.
    func toggleToday(_ habit: Habit) {
        if isCompletedToday(habit) {
            // Si ya estaba completado, lo desmarcamos.
            habit.completedDates.removeAll { $0.isSameDay(as: Date()) }
        } else {
            // Si no estaba completado, añadimos la fecha de hoy.
            habit.completedDates.append(Date())
        }
        save()
    }
    
    /// Calcula la racha actual (días consecutivos hacia atrás desde hoy).
    func currentStreak(for habit: Habit) -> Int {
        let calendar = Calendar.current
        
        // Obtenemos los días únicos completados, ordenados de más reciente a más antiguo.
        let completedDays = Set(
            habit.completedDates.map { $0.startOfDay }
        ).sorted(by: >)
        
        guard !completedDays.isEmpty else { return 0 }
        
        var streak = 0
        // Empezamos desde hoy. Si no completó hoy, la racha es 0.
        var checkDate = Date().startOfDay
        
        for day in completedDays {
            if day == checkDate {
                streak += 1
                // El siguiente día a revisar es el día anterior.
                checkDate = calendar.date(byAdding: .day, value: -1, to: checkDate)!
            } else {
                // Hay un hueco — la racha se rompió.
                break
            }
        }
        
        return streak
    }
    
    // MARK: - Persistencia
    
    private func save() {
        do {
            try modelContext.save()
        } catch {
            print("❌ Error guardando datos: \(error.localizedDescription)")
        }
    }
}
