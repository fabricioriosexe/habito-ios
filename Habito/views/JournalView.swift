import SwiftUI
import SwiftData

struct JournalView: View {
    @Environment(\.modelContext) private var modelContext
    // order: .reverse = las más recientes primero
    @Query(sort: \JournalEntry.createdAt, order: .reverse)
    private var entries: [JournalEntry]

    @State private var showingNewEntry = false
    @State private var showingChat = false
    @State private var selectedEntry: JournalEntry?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    AICompanionPreviewCard(entries: entries)
                        .padding(.horizontal).padding(.top, 12)
                        .onTapGesture { showingChat = true }

                    if entries.isEmpty {
                        emptyJournalState.padding(.top, 40)
                    } else {
                        LazyVStack(spacing: 12) {
                            ForEach(entries) { entry in
                                JournalEntryCard(entry: entry)
                                    .onTapGesture { selectedEntry = entry }
                            }
                        }
                        .padding(.horizontal).padding(.top, 16).padding(.bottom, 32)
                    }
                }
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Mi diario")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button { showingNewEntry = true } label: {
                        Image(systemName: "square.and.pencil").font(.title3)
                    }
                }
            }
            // sheet = pantalla modal que sube desde abajo
            .sheet(isPresented: $showingNewEntry) {
                NewEntryView { content, mood in
                    let entry = JournalEntry(content: content, mood: mood)
                    modelContext.insert(entry)
                    try? modelContext.save()
                }
            }
            .sheet(isPresented: $showingChat) {
                // Pasamos las últimas 5 entradas a la IA como contexto
                AICompanionView(recentEntries: Array(entries.prefix(5)))
            }
            // sheet(item:) — se abre cuando selectedEntry tiene valor
            .sheet(item: $selectedEntry) { entry in
                EntryDetailView(entry: entry)
            }
        }
    }

    private var emptyJournalState: some View {
        VStack(spacing: 16) {
            Text("📓").font(.system(size: 48))
            Text("Tu diario está vacío").font(.title3).fontWeight(.semibold)
            Text("Tocá el lápiz para escribir tu primera entrada")
                .font(.subheadline).foregroundStyle(.secondary)
                .multilineTextAlignment(.center).padding(.horizontal, 32)
        }
    }
}

struct JournalEntryCard: View {
    let entry: JournalEntry
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(entry.mood).font(.title3)
                Text(entry.createdAt, style: .date)
                    .font(.caption).fontWeight(.medium).foregroundStyle(.secondary)
                Spacer()
                Text(entry.createdAt, style: .time)
                    .font(.caption2).foregroundStyle(.tertiary)
            }
            Text(entry.content)
                .font(.body).foregroundStyle(.primary)
                .lineLimit(4).multilineTextAlignment(.leading)
        }
        .padding(16).frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(RoundedRectangle(cornerRadius: 14).strokeBorder(Color.indigo.opacity(0.15), lineWidth: 1))
    }
}

struct AICompanionPreviewCard: View {
    let entries: [JournalEntry]
    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle().fill(Color.indigo.opacity(0.12)).frame(width: 44, height: 44)
                Text("✦").font(.title2)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text("Habito IA").font(.subheadline).fontWeight(.semibold)
                Text(entries.isEmpty ? "Contame cómo estás hoy" : "¿Querés hablar de lo que escribiste?")
                    .font(.caption).foregroundStyle(.secondary)
            }
            Spacer()
            Image(systemName: "chevron.right").font(.caption).foregroundStyle(.secondary)
        }
        .padding(14)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(RoundedRectangle(cornerRadius: 14).strokeBorder(Color.indigo.opacity(0.3), lineWidth: 1))
    }
}

struct NewEntryView: View {
    @Environment(\.dismiss) private var dismiss
    let onSave: (String, String) -> Void
    @State private var content = ""
    @State private var selectedMood = "😐"
    let moods = ["😊","😐","😔","😤","😰","🥹","💪"]

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("¿Cómo estás?").font(.subheadline).foregroundStyle(.secondary).padding(.horizontal)
                    HStack(spacing: 12) {
                        ForEach(moods, id: \.self) { mood in
                            Text(mood).font(.title2)
                                .padding(8)
                                .background(Circle().fill(selectedMood == mood ? Color.indigo.opacity(0.15) : Color.clear))
                                .scaleEffect(selectedMood == mood ? 1.2 : 1.0)
                                .onTapGesture { withAnimation(.spring(duration: 0.2)) { selectedMood = mood } }
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.top)

                ZStack(alignment: .topLeading) {
                    if content.isEmpty {
                        Text("Escribí lo que tenés en mente...")
                            .foregroundStyle(.tertiary).padding(.top, 8).padding(.leading, 4)
                    }
                    TextEditor(text: $content)
                        .scrollContentBackground(.hidden).frame(minHeight: 200)
                }
                .padding(.horizontal).font(.body)
                Spacer()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Nueva entrada")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancelar") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Guardar") { onSave(content, selectedMood); dismiss() }
                        .fontWeight(.semibold)
                        .disabled(content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
}

struct EntryDetailView: View {
    @Environment(\.dismiss) private var dismiss
    let entry: JournalEntry
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    HStack(spacing: 12) {
                        Text(entry.mood).font(.title)
                        VStack(alignment: .leading) {
                            Text(entry.createdAt, style: .date).font(.headline)
                            Text(entry.createdAt, style: .time).font(.caption).foregroundStyle(.secondary)
                        }
                    }
                    Divider()
                    Text(entry.content).font(.body).lineSpacing(6)
                }
                .padding()
            }
            .navigationTitle("Entrada").navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .confirmationAction) { Button("Listo") { dismiss() } } }
        }
    }
}
