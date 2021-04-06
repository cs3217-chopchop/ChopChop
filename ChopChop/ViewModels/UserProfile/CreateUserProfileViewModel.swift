import Combine
import Foundation
import UIKit

final class CreateUserProfileViewModel: ObservableObject {
    private var settings: UserSettings

    @Published var name: String = ""
    private let storageManager = StorageManager()
    @Published var errorMessage = ""

    init(settings: UserSettings) {
        self.settings = settings
    }

    func onClick() {
        guard settings.userId == nil else {
            assertionFailure()
            return
        }

        guard let newUser = try? User(name: name) else {
            errorMessage = "Empty name not accepted"
            return
        }
        guard let userId = try? storageManager.createUser(user: newUser) else {
            assertionFailure()
            return
        }
        UserDefaults.standard.set(userId, forKey: "userId")
        settings.userId = userId
    }

}
