import SwiftUI
import SwiftData

struct CalendarView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Habit.createdAt) private var habits: [Habit]
    @State private var viewModel: HabitViewModel?
    @State private var selectedMonth = Date()

    private let calendar = Calendar.current
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 4), count: 7)
    private let weekdays = ["Lu","Ma","Mi","Ju","Vi","Sa","Do"]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    if let vm = viewModel {
                        // Tarjetas de stats
                        HStack(spacing: 12) {
                            StatCard(label: "Mejor racha", value: "\(vm.bestStreak(habits: habits)) 🔥")
                            StatCard(label: "Tasa del mes", value: "\(vm.monthCompletionRate(habits: habits))%")
                        }
                        .padding(.horizontal)

                        // Navegación de mes
                        HStack {
                            Button { changeMonth(by: -1) } label: {
                                Image(systemName: "chevron.left").font(.title3).foregroundStyle(.indigo)
                            }
                            Spacer()
                            Text(monthTitle).font(.headline)
                            Spacer()
                            Button { changeMonth(by: 1) } label: {
                                Image(systemName: "chevron.right").font(.title3).foregroundStyle(.indigo)
                            }
                        }
                        .padding(.horizontal, 24)

                        // Grilla del calendario
                        VStack(spacing: 4) {
                            HStack(spacing: 4) {
                                ForEach(weekdays, id: \.self) { day in
                                    Text(day)
                                        .font(.caption2).fontWeight(.medium)
                                        .foregroundStyle(.secondary)
                                        .frame(maxWidth: .infinity)
                                }
                            }
                            .padding(.horizontal)

                            LazyVGrid(columns: columns, spacing: 4) {
                                // Celdas vacías para alinear el primer día con su día de semana
                                ForEach(0..<firstWeekdayOffset, id: \.self) { _ in
                                    Color.clear.frame(height: 36)
                                }
                                ForEach(daysInMonth, id: \.self) { date in
                                    CalendarDayCell(
                                        date: date,
                                        intensity: vm.intensity(on: date, habits: habits),
                                        isToday: calendar.isDateInToday(date),
                                        isFuture: date > Date()
                                    )
                                }
                            }
                            .padding(.horizontal)
                        }
                        .padding(.vertical, 8)
                        .background(Color(.systemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .padding(.horizontal)

                        // Leyenda de intensidad
                        HStack(spacing: 6) {
                            Text("Menos").font(.caption2).foregroundStyle(.secondary)
                            ForEach(0..<5, id: \.self) { i in
                                RoundedRectangle(cornerRadius: 3)
                                    .fill(intensityColor(Double(i) / 4.0))
                                    .frame(width: 16, height: 16)
                            }
                            Text("Más").font(.caption2).foregroundStyle(.secondary)
                        }
                    }
                }
                .padding(.vertical)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Mi mes")
        }
        .onAppear {
            if viewModel == nil {
                viewModel = HabitViewModel(modelContext: modelContext)
            }
        }
    }

    // MARK: - Helpers

    private var monthTitle: String {
        let f = DateFormatter()
        f.dateFormat = "MMMM yyyy"
        f.locale = Locale(identifier: "es_AR")
        return f.string(from: selectedMonth).capitalized
    }

    private var daysInMonth: [Date] {
        guard let range = calendar.range(of: .day, in: .month, for: selectedMonth),
              let start = calendar.date(from: calendar.dateComponents([.year,.month], from: selectedMonth))
        else { return [] }
        return range.compactMap { calendar.date(byAdding: .day, value: $0 - 1, to: start) }
    }

    // Offset para empezar la grilla en lunes (0=Lu ... 6=Do)
    private var firstWeekdayOffset: Int {
        guard let first = daysInMonth.first else { return 0 }
        let weekday = calendar.component(.weekday, from: first)
        return (weekday + 5) % 7
    }

    private func changeMonth(by value: Int) {
        if let newDate = calendar.date(byAdding: .month, value: value, to: selectedMonth) {
            selectedMonth = newDate
        }
    }

    func intensityColor(_ intensity: Double) -> Color {
        // Rampa de ámbar: de casi blanco a oscuro intenso
        let colors: [Color] = [
            Color(hex: "#FEF9EC") ?? .clear,
            Color(hex: "#FAC775") ?? .clear,
            Color(hex: "#EF9F27") ?? .clear,
            Color(hex: "#BA7517") ?? .clear,
            Color(hex: "#854F0B") ?? .clear
        ]
        guard intensity > 0 else { return Color.secondary.opacity(0.12) }
        let index = min(Int(intensity * Double(colors.count - 1)), colors.count - 1)
        return colors[index]
    }
}

// MARK: - Celda del calendario

struct CalendarDayCell: View {
    let date: Date
    let intensity: Double
    let isToday: Bool
    let isFuture: Bool
    private let calendar = Calendar.current

    private func intensityColor(_ v: Double) -> Color {
        let colors: [Color] = [
            Color(hex: "#FEF9EC") ?? .clear,
            Color(hex: "#FAC775") ?? .clear,
            Color(hex: "#EF9F27") ?? .clear,
            Color(hex: "#BA7517") ?? .clear,
            Color(hex: "#854F0B") ?? .clear
        ]
        guard v > 0 else { return Color.secondary.opacity(0.12) }
        let index = min(Int(v * Double(colors.count - 1)), colors.count - 1)
        return colors[index]
    }

    var body: some View {
        let day = calendar.component(.day, from: date)
        ZStack {
            RoundedRectangle(cornerRadius: 6)
                .fill(isFuture ? Color.clear : intensityColor(intensity))
            if isToday {
                RoundedRectangle(cornerRadius: 6)
                    .strokeBorder(Color.indigo, lineWidth: 2)
            }
            Text("\(day)")
                .font(.system(size: 11, weight: isToday ? .bold : .regular))
                .foregroundStyle(isFuture ? Color.secondary.opacity(0.3) : dayTextColor)
        }
        .frame(height: 36)
    }

    private var dayTextColor: Color {
        if intensity > 0.6 { return Color(hex: "#FEF9EC") ?? .white }
        if intensity > 0   { return Color(hex: "#412402") ?? .primary }
        return .secondary
    }
}

// MARK: - Tarjeta de estadística

struct StatCard: View {
    let label: String
    let value: String
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label).font(.caption).foregroundStyle(.secondary)
            Text(value).font(.title2).fontWeight(.semibold)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
