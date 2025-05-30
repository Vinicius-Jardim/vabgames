import Foundation

class LanguageManager: ObservableObject {
    static let shared = LanguageManager()
    @Published var currentLanguage: String {
        didSet {
            UserDefaults.standard.set(currentLanguage, forKey: "MyLanguages")
        }
    }
    
    init() {
        self.currentLanguage = UserDefaults.standard.string(forKey: "MyLanguages") ?? Locale.current.language.languageCode?.identifier ?? "en"
    }
    
    func setLanguage(_ language: String) {
        currentLanguage = language
        UserDefaults.standard.set([language], forKey: "AppleLanguages")
        UserDefaults.standard.synchronize()
    }
}
