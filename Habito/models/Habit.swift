import Foundation
import SwiftData

// @Model le dice a SwiftData:
// "esta clase es una tabla en la base de datos"
// Swift genera todo el SQL por debajo — vos no lo ves nunca
@Model
final class Habit {

    var id: UUID           // Identificador único — nunca dos iguales
    var name: String       // "Meditar", "Leer", etc.
    var colorHex: String   // "#5E5CE6" — el color elegido
    var createdAt: Date    // Cuándo se creó el hábito
    var completedDates: [Date]  // Historial de días completados

    init(name: String, colorHex: String = "#5E5CE6") {
        self.id = UUID()           // Genera un ID único automáticamente
        self.name = name
        self.colorHex = colorHex
        self.createdAt = Date()    // "ahora mismo"
        self.completedDates = []   // Empieza vacío
    }
}
