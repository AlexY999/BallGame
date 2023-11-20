import Foundation

class UserDefaultsManager {
    
    // MARK: - Keys
    static let winnerURLKey = "WinnerURL"
    static let loserURLKey = "LoserURL"

    // MARK: - Public Methods

    static func saveWinnerURL(_ url: URL) {
        UserDefaultsManager.saveURL(url, forKey: winnerURLKey)
    }

    static func saveLoserURL(_ url: URL) {
        UserDefaultsManager.saveURL(url, forKey: loserURLKey)
    }

    static func getWinnerURL() -> URL? {
        UserDefaultsManager.getURL(forKey: winnerURLKey)
    }

    static func getLoserURL() -> URL? {
        return UserDefaultsManager.getURL(forKey: UserDefaultsManager.loserURLKey)
    }

    // MARK: - Private Methods

    private static func saveURL(_ url: URL, forKey key: String) {
        UserDefaults.standard.set(url.absoluteString, forKey: key)
    }

    private static func getURL(forKey key: String) -> URL? {
        guard let urlString = UserDefaults.standard.string(forKey: key), let url = URL(string: urlString) else {
            return nil
        }
        return url
    }
}
