import SwiftUI
import SwiftData

struct HabitListView: View {

    // @Environment(\.modelContext) inyecta el contexto creado
    // en HabitoApp.swift — la vista nunca escribe datos directamente.
    @Environment(\.modelContext) private var modelContext

    // @Query observa la base de datos en tiempo real.
    // Cuando el ViewModel inserta o borra un Habit, esta lista
    // se actualiza automáticamente sin ningún código extra.
    @Query(sort: \Habit.createdAt, order: .forward)
    private var habits: [Habit]

    @State private var viewModel: HabitViewModel?
    @State private var showingAddHabit = false

    var body: some View {
        NavigationStack {
            Group {
                if let vm = viewModel {
                    contentView(vm: vm)
                }
            }
            .navigationTitle("Habito")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingAddHabit = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title3)
                    }
                }
            }
            .sheet(isPresented: $showingAddHabit) {
                if let vm = viewModel {
                    AddHabitView(viewModel: vm)
                }
            }
        }
        .onAppear {
            if viewModel == nil {
                viewModel = HabitViewModel(modelContext: modelContext)
            }
        }
    }

    @ViewBuilder
    private func contentView(vm: HabitViewModel) -> some View {
        if habits.isEmpty {
            emptyState
        } else {
            List {
                ForEach(habits) { habit in
                    HabitRowView(
                        habit: habit,
                        isCompleted: vm.isCompletedToday(habit),
                        streak: vm.currentStreak(for: habit),
                        onToggle: { vm.toggleToday(habit) }
                    )
                }
                .onDelete { offsets in
                    vm.deleteHabits(habits, at: offsets)
                }
            }
            .listStyle(.insetGrouped)
        }
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 52))
                .foregroundStyle(.indigo.opacity(0.4))

            Text("Tu primer hábito te espera")
                .font(.title3)
                .fontWeight(.semibold)

            Text("Toca + para empezar tu racha")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
}
