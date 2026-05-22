import Foundation

extension Date {
    // "extension" significa: le añado funciones nuevas
    // a un tipo que ya existe (Date), sin modificar Apple.

    func isSameDay(as other: Date) -> Bool {
        // Calendar.current = el calendario del iPhone del usuario
        // (respeta su zona horaria automáticamente)
        Calendar.current.isDate(self, inSameDayAs: other)
    }

    var startOfDay: Date {
        // Convierte "17/05/2026 14:32" en "17/05/2026 00:00"
        // Lo usamos para comparar días sin importar la hora exacta
        Calendar.current.startOfDay(for: self)
    }
}
