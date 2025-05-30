import SwiftUI
import CoreData

struct BlacklistView: View {
    @AppStorage("MyLanguages") var currentLanguages: String = Locale.current.language.languageCode?.identifier ?? "en"
    @FetchRequest(
        entity: BlacklistedPublisher.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \BlacklistedPublisher.timestamp, ascending: false)]
    ) private var blacklistedPublishers: FetchedResults<BlacklistedPublisher>
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background Gradient
                LinearGradient(
                    gradient: Gradient(colors: [Color.purple.opacity(0.8), Color.orange.opacity(0.7)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                if blacklistedPublishers.isEmpty {
                    // Empty State
                    VStack(spacing: 16) {
                        Image(systemName: "exclamationmark.circle")
                            .font(.system(size: 60))
                            .foregroundColor(.secondary)
                        Text("no_publishers_blacklist".localised(using: currentLanguages))
                            .foregroundColor(.secondary)
                            .font(.title3)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                } else {
                    List {
                        ForEach(blacklistedPublishers, id: \.self) { publisher in
                            HStack {
                                VStack(alignment: .leading, spacing: 8) {
                                    // Publisher Name
                                    Text(publisher.name ?? "Unknown Publisher")
                                        .font(.headline)
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                    
                                    // Timestamp
                                    if let timestamp = publisher.timestamp {
                                        Text("\("added_on".localised(using: currentLanguages)) \(timestamp, formatter: dateFormatter)")
                                            .font(.caption)
                                            .foregroundColor(.white.opacity(0.8))
                                    }
                                }
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.orange.opacity(0.4)) // Laranja claro translúcido
                                        .shadow(color: Color.black.opacity(0.3), radius: 5, x: 0, y: 3)
                                )
                                
                                Spacer()
                                
                                // Remove Button
                                Button {
                                    withAnimation {
                                        BlacklistManager.shared.removeFromBlacklist(publisher.id ?? 0)
                                    }
                                } label: {
                                    HStack {
                                        Image(systemName: "trash.fill")
                                            .font(.title3)
                                        Text("Remove")
                                            .font(.footnote)
                                            .fontWeight(.bold)
                                    }
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                    .foregroundColor(.white)
                                    .background(LinearGradient(
                                        gradient: Gradient(colors: [Color.orange, Color.red]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    ))
                                    .clipShape(Capsule())
                                    .shadow(color: Color.black.opacity(0.2), radius: 3, x: 0, y: 3)
                                }
                            }
                            .padding(.vertical, 6)
                        }
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear) // Remove o fundo branco do card padrão
                    }
                    .listStyle(PlainListStyle())
                    .background(Color.clear) // Remove o fundo branco do List
                }
            }
            .navigationTitle("blacklist".localised(using: currentLanguages))
        }
    }
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }
}
