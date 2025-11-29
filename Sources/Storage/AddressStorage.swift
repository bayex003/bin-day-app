import Foundation

final class AddressStorage {
    static let shared = AddressStorage()

    private let key = "storedAddress"

    private init() {}

    func save(_ address: AddressItem) {
        do {
            let data = try JSONEncoder().encode(address)
            UserDefaults.standard.set(data, forKey: key)
        } catch {
            print("Failed to save address:", error)
        }
    }

    func load() -> AddressItem? {
        guard let data = UserDefaults.standard.data(forKey: key) else {
            return nil
        }

        do {
            let address = try JSONDecoder().decode(AddressItem.self, from: data)
            return address
        } catch {
            print("Failed to load address:", error)
            return nil
        }
    }

    func clear() {
        UserDefaults.standard.removeObject(forKey: key)
    }
}
