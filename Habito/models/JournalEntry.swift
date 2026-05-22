import Foundation
import SwiftData

@Model
final class JournalEntry {

    var id: UUID
    var content: String   // El texto de la entrada del diario
    var createdAt: Date
    var mood: String      // Un emoji: "😊", "😔", etc.

    init(content: String, mood: String = "😐") {
        self.id = UUID()
        self.content = content
        self.createdAt = Date()
        self.mood = mood
    }
}
