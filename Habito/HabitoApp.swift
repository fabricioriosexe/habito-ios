import SwiftUI
import SwiftData

@main
struct HabitoApp: App {
    var body: some Scene {
        WindowGroup {
            HabitListView()
        }
        // SwiftData necesita saber qué modelos gestionar.
        // .modelContainer crea la base de datos SQLite automáticamente.
        .modelContainer(for: Habit.self)
    }
}
