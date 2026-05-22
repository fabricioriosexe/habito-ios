import Foundation

enum Config {
    static var groqAPIKey: String {
        guard let key = Bundle.main.infoDictionary?["GROQ_API_KEY"] as? String else {
            print("⚠️ Habito — GROQ_API_KEY no encontrada en Info.plist")
            return ""
        }
        // .trimmingCharacters elimina espacios y saltos de línea invisibles
        // que a veces se cuelan desde el xcconfig
        let clean = key.trimmingCharacters(in: .whitespacesAndNewlines)
        print("🔑 Key limpia, largo: \(clean.count) caracteres")
        return clean
    }
}
