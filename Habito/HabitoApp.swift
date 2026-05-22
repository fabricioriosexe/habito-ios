import SwiftUI
import SwiftData

@main  // Le dice a Swift: "acá empieza la app"
struct HabitoApp: App {
    var body: some Scene {
        WindowGroup {
            MainTabView()
        }
        // Registramos ambos modelos.
        // SwiftData crea el archivo SQLite automáticamente
        // en el directorio de la app (el usuario no lo ve)
        .modelContainer(for: [Habit.self, JournalEntry.self])
    }
}

struct MainTabView: View {
    var body: some View {
        TabView {
            HabitListView()
                .tabItem { Label("Hábitos", systemImage: "checkmark.circle") }

            CalendarView()
                .tabItem { Label("Mes", systemImage: "calendar") }

            JournalView()
                .tabItem { Label("Diario", systemImage: "book.closed") }
        }
        .tint(.indigo)  // Color de acento de toda la app
    }
}
