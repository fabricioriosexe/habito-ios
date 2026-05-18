import Foundation

extension Date {
    /// Retorna true si dos fechas son el mismo día calendario.
    func isSameDay(as other: Date) -> Bool {
        Calendar.current.isDate(self, inSameDayAs: other)
    }
    
    /// Retorna el inicio del día (medianoche) de esta fecha.
    var startOfDay: Date {
        Calendar.current.startOfDay(for: self)
    }
}
