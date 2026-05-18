import SwiftUI

extension Color {
    /// Crea un Color desde un string hexadecimal "#RRGGBB".
    init?(hex: String) {
        let hex = hex.trimmingCharacters(in: .init(charactersIn: "#"))
        guard hex.count == 6,
              let intVal = UInt64(hex, radix: 16) else { return nil }

        let r = Double((intVal >> 16) & 0xFF) / 255.0
        let g = Double((intVal >> 8)  & 0xFF) / 255.0
        let b = Double( intVal        & 0xFF) / 255.0

        self.init(red: r, green: g, blue: b)
    }
}
