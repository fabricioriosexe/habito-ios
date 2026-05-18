import Foundation
import SwiftData

@Model
final class Habit {
    
    // MARK: - Propiedades
    var id: UUID
    var name: String
    var colorHex: String
    var createdAt: Date
    
    // Guardamos las fechas en que el hábito fue completado.
    // Usamos [Date] para simplicidad en nuestro MVP.
    var completedDates: [Date]
    
    // MARK: - Inicializador
    init(
        name: String,
        colorHex: String = "#6C63FF"
    ) {
        self.id = UUID()
        self.name = name
        self.colorHex = colorHex
        self.createdAt = Date()
        self.completedDates = []
    }
}
