import SwiftUI

struct ChatMessage: Identifiable {
    let id = UUID()
    let role: String
    let content: String
}

struct AICompanionView: View {
    @Environment(\.dismiss) private var dismiss
    let recentEntries: [JournalEntry]

    @State private var messages: [ChatMessage] = []
    @State private var inputText = ""
    @State private var isLoading = false

    private var systemPrompt: String {
        let entriesSummary = recentEntries.prefix(3).map {
            "[\($0.mood)] \($0.content.prefix(200))"
        }.joined(separator: "\n---\n")

        return """
        Sos un compañero de bienestar dentro de la app Habito. \
        No sos un terapeuta — sos un amigo empático, cálido y presente.
        Hablás en español rioplatense (vos, acá, andá).
        Hacés UNA sola pregunta por vez.
        Tus respuestas son cortas (máximo 3 oraciones).
        Celebrás los logros sin exagerar.
        Cuando alguien está mal, no minimizás ni das soluciones inmediatas.

        Entradas recientes del diario:
        \(entriesSummary.isEmpty ? "No hay entradas aún." : entriesSummary)
        """
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {

                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            if messages.isEmpty {
                                WelcomeMessageView().padding(.top, 20)
                            }
                            ForEach(messages) { msg in
                                ChatBubble(message: msg).id(msg.id)
                            }
                            if isLoading {
                                HStack { TypingIndicator(); Spacer() }
                            }
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 12)
                    }
                    .onChange(of: messages.count) { _, _ in
                        if let last = messages.last {
                            withAnimation { proxy.scrollTo(last.id, anchor: .bottom) }
                        }
                    }
                }

                Divider()

                HStack(spacing: 10) {
                    TextField("Escribí algo...", text: $inputText, axis: .vertical)
                        .lineLimit(1...4)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .background(Color(.systemGray6))
                        .clipShape(RoundedRectangle(cornerRadius: 20))

                    Button { sendMessage() } label: {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.title2)
                            .foregroundStyle(
                                inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                                ? Color.secondary : Color.indigo
                            )
                    }
                    .disabled(
                        inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                        || isLoading
                    )
                }
                .padding(.horizontal)
                .padding(.vertical, 10)
                .background(Color(.systemBackground))
            }
            .navigationTitle("Habito IA ✦")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cerrar") { dismiss() }
                }
            }
        }
    }

    // MARK: - Lógica

    private func sendMessage() {
        let text = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        messages.append(ChatMessage(role: "user", content: text))
        inputText = ""
        isLoading = true
        Task { await callGroqAPI() }
    }

    private func callGroqAPI() async {
        print("🔑 Key completa: '\(Config.groqAPIKey)'")
        print("🔑 Largo de la key: \(Config.groqAPIKey.count) caracteres")
        let key = Config.groqAPIKey
        print("🔑 Habito — Groq Key: \(key.isEmpty ? "VACÍA ❌" : "OK ✓ (\(key.prefix(8))...)")")

        guard !key.isEmpty else {
            await handleError("La API key está vacía. Revisá la configuración.")
            return
        }

        // Groq usa formato OpenAI — el system prompt va como mensaje "system"
        // Es mucho más limpio que Gemini
        var apiMessages: [[String: String]] = [
            ["role": "system", "content": systemPrompt]
        ]
        for msg in messages {
            apiMessages.append(["role": msg.role, "content": msg.content])
        }

        let body: [String: Any] = [
            "model": "llama-3.3-70b-versatile",
            "messages": apiMessages,
            "max_tokens": 1024,
            "temperature": 0.8
        ]

        guard let url = URL(string: "https://api.groq.com/openai/v1/chat/completions"),
              let bodyData = try? JSONSerialization.data(withJSONObject: body)
        else {
            await handleError("Error construyendo el request")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(key)", forHTTPHeaderField: "Authorization")
        request.httpBody = bodyData
        request.timeoutInterval = 30

        do {
            print("🚀 Habito — Enviando a Groq...")
            let (data, response) = try await URLSession.shared.data(for: request)

            if let httpResponse = response as? HTTPURLResponse {
                print("📡 Habito — HTTP Status: \(httpResponse.statusCode)")

                if httpResponse.statusCode != 200 {
                    let raw = String(data: data, encoding: .utf8) ?? "sin body"
                    print("❌ Habito — Error Groq: \(raw)")
                    await handleError("Error \(httpResponse.statusCode) — revisá la consola")
                    return
                }
            }

            // Groq devuelve: choices[0].message.content
            if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let choices = json["choices"] as? [[String: Any]],
               let first = choices.first,
               let message = first["message"] as? [String: Any],
               let text = message["content"] as? String {

                print("✅ Habito — Respuesta OK: \(text.prefix(60))...")
                await MainActor.run {
                    messages.append(ChatMessage(role: "assistant", content: text))
                    isLoading = false
                }
            } else {
                let raw = String(data: data, encoding: .utf8) ?? ""
                print("❌ Habito — No se pudo parsear: \(raw.prefix(300))")
                await handleError("No entendí la respuesta de la IA")
            }

        } catch let urlError as URLError {
            print("❌ Habito — URLError \(urlError.code.rawValue): \(urlError.localizedDescription)")
            switch urlError.code {
            case .notConnectedToInternet:
                await handleError("Sin conexión a internet")
            case .timedOut:
                await handleError("La IA tardó demasiado, intentá de nuevo")
            default:
                await handleError("Error de red: \(urlError.localizedDescription)")
            }
        } catch {
            print("❌ Habito — Error inesperado: \(error)")
            await handleError("Error inesperado, intentá de nuevo")
        }
    }

    @MainActor
    private func handleError(_ message: String) {
        messages.append(ChatMessage(role: "assistant", content: message))
        isLoading = false
    }
}

// MARK: - Componentes visuales (sin cambios)

struct ChatBubble: View {
    let message: ChatMessage
    var isUser: Bool { message.role == "user" }

    var body: some View {
        HStack {
            if isUser { Spacer(minLength: 60) }
            Text(message.content)
                .font(.body)
                .foregroundStyle(isUser ? .white : .primary)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 18)
                        .fill(isUser ? Color.indigo : Color(.systemGray6))
                )
            if !isUser { Spacer(minLength: 60) }
        }
    }
}

struct TypingIndicator: View {
    @State private var animate = false
    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<3, id: \.self) { i in
                Circle()
                    .fill(Color.secondary.opacity(0.5))
                    .frame(width: 7, height: 7)
                    .offset(y: animate ? -4 : 0)
                    .animation(
                        .easeInOut(duration: 0.4).repeatForever().delay(Double(i) * 0.13),
                        value: animate
                    )
            }
        }
        .padding(.horizontal, 14).padding(.vertical, 12)
        .background(RoundedRectangle(cornerRadius: 18).fill(Color(.systemGray6)))
        .onAppear { animate = true }
    }
}

struct WelcomeMessageView: View {
    var body: some View {
        VStack(spacing: 12) {
            Text("✦").font(.system(size: 40))
            Text("Habito IA").font(.title3).fontWeight(.semibold)
            Text("Estoy acá para escucharte.")
                .font(.subheadline).foregroundStyle(.secondary)
                .multilineTextAlignment(.center).padding(.horizontal, 32)
        }
        .padding(.bottom, 20)
    }
}
