import SwiftUI
import SwiftData

struct HabitListView: View {

    // @Environment inyecta valores que SwiftUI pasa
    // automáticamente a todas las vistas.
    // modelContext viene del .modelContainer() en HabitoApp.
    @Environment(\.modelContext) private var modelContext

    // @Query es la magia de SwiftData:
    // "dame todos los Habit ordenados por createdAt"
    // y actualiza la lista automáticamente cuando cambia algo.
    @Query(sort: \Habit.createdAt, order: .forward)
    private var habits: [Habit]

    // @State = estado local de esta vista, SwiftUI lo gestiona
    @State private var viewModel: HabitViewModel?
    @State private var showingAddHabit = false

    var body: some View {
        NavigationStack {
            Group {
                if let vm = viewModel {  // "if let" desenvuelve el Optional
                    contentView(vm: vm)
                }
            }
            .navigationTitle("Habito")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button { showingAddHabit = true } label: {
                        Image(systemName: "plus.circle.fill").font(.title3)
                    }
                }
            }
            .sheet(isPresented: $showingAddHabit) {
                // $ = Binding: la vista hija puede cambiar este valor
                if let vm = viewModel { AddHabitView(viewModel: vm) }
            }
        }
        .onAppear {
            // onAppear = cuando la vista aparece en pantalla
            // Inicializamos el ViewModel UNA SOLA VEZ
            if viewModel == nil {
                viewModel = HabitViewModel(modelContext: modelContext)
            }
        }
    }

    @ViewBuilder  // Le dice a Swift que este método construye vistas
    private func contentView(vm: HabitViewModel) -> some View {
        List {
            if !habits.isEmpty {
                Section {
                    DayFireBannerView(
                        completedCount: habits.filter { vm.isCompletedToday($0) }.count,
                        totalCount: habits.count,
                        allDone: vm.allCompletedToday(habits)
                    )
                }
                .listRowInsets(EdgeInsets())
                .listRowBackground(Color.clear)
            }

            if habits.isEmpty {
                Section {
                    emptyState
                }.listRowBackground(Color.clear)
            } else {
                Section {
                    ForEach(habits) { habit in
                        HabitRowView(
                            habit: habit,
                            isCompleted: vm.isCompletedToday(habit),
                            streak: vm.currentStreak(for: habit),
                            onToggle: { vm.toggleToday(habit) }
                        )
                    }
                    .onDelete { vm.deleteHabits(habits, at: $0) }
                }
            }
        }
        .listStyle(.insetGrouped)
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 52))
                .foregroundStyle(.indigo.opacity(0.4))
            Text("Tu primer hábito te espera")
                .font(.title3).fontWeight(.semibold)
            Text("Toca + para empezar tu racha")
                .font(.subheadline).foregroundStyle(.secondary)
        }
        .padding().frame(maxWidth: .infinity)
    }
}

// MARK: - Banner del fuego del día

struct DayFireBannerView: View {
    let completedCount: Int
    let totalCount: Int
    let allDone: Bool

    var body: some View {
        HStack(spacing: 12) {
            Text(allDone ? "🏆" : "🔥").font(.title2)

            VStack(alignment: .leading, spacing: 2) {
                Text(allDone ? "¡Día completo!" : "\(completedCount) de \(totalCount) hábitos")
                    .font(.subheadline).fontWeight(.semibold)
                    .foregroundStyle(allDone ? Color.orange : .primary)
                Text(allDone ? "Ganaste el fuego del día 🔥" : "Completá todos para el fuego del día")
                    .font(.caption).foregroundStyle(.secondary)
            }

            Spacer()

            HStack(spacing: 4) {
                ForEach(0..<totalCount, id: \.self) { i in
                    Circle()
                        .fill(i < completedCount ? Color.orange : Color.secondary.opacity(0.25))
                        .frame(width: 8, height: 8)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(allDone ? Color.orange.opacity(0.12) : Color.secondary.opacity(0.07))
        )
        .padding(.horizontal, 16)
        .padding(.top, 8)
        .animation(.spring(duration: 0.3), value: completedCount)
    }
}
