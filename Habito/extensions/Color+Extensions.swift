import SwiftUI

extension Color {
    // Le añadimos a Color la capacidad de crearse
    // desde un string "#FF5733" (hex)
    init?(hex: String) {
        // Sacamos el # del principio si existe
        let hex = hex.trimmingCharacters(in: .init(charactersIn: "#"))
        
        // Verificamos que tenga exactamente 6 caracteres
        // y que se pueda convertir a número hexadecimal
        guard hex.count == 6,
              let intVal = UInt64(hex, radix: 16) else { return nil }

        // Separamos los 6 dígitos en 3 pares: RR GG BB
        // >> es "desplazamiento de bits" — forma estándar de extraer canales de color
        let r = Double((intVal >> 16) & 0xFF) / 255.0
        let g = Double((intVal >> 8)  & 0xFF) / 255.0
        let b = Double( intVal        & 0xFF) / 255.0

        self.init(red: r, green: g, blue: b)
    }
}
