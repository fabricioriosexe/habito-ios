import SwiftUI

struct AddHabitView: View {

    @Environment(\.dismiss) private var dismiss

    let viewModel: HabitViewModel

    @State private var habitName: String = ""
    @State private var selectedColor: String = "#5E5CE6"

    private let colorOptions: [String] = [
        "#5E5CE6", // Índigo Apple
        "#FF375F", // Rosa
        "#30D158", // Verde
        "#FF9F0A", // Ámbar
        "#0A84FF", // Azul
        "#BF5AF2"  // Púrpura
    ]

    var body: some View {
        NavigationStack {
            Form {
                Section("Nombre del hábito") {
                    TextField("Ej: Meditar, Leer, Correr…", text: $habitName)
                }

                Section("Color") {
                    LazyVGrid(
                        columns: Array(repeating: GridItem(.flexible()), count: 6),
                        spacing: 14
                    ) {
                        ForEach(colorOptions, id: \.self) { hex in
                            let color = Color(hex: hex) ?? .indigo
                            let isSelected = selectedColor == hex

                            Circle()
                                .fill(color)
                                .frame(width: 36, height: 36)
                                .overlay(
                                    Circle()
                                        .strokeBorder(.white, lineWidth: 2.5)
                                        .opacity(isSelected ? 1 : 0)
                                )
                                .scaleEffect(isSelected ? 1.15 : 1.0)
                                .onTapGesture { selectedColor = hex }
                                .animation(.spring(duration: 0.2), value: selectedColor)
                        }
                    }
                    .padding(.vertical, 8)
                }
            }
            .navigationTitle("Nuevo hábito")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Guardar") {
                        viewModel.addHabit(name: habitName, colorHex: selectedColor)
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .disabled(habitName.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }
}
