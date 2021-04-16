import Combine
import Foundation
import UIKit

final class CreateUserProfileViewModel: ObservableObject {
    private let settings: UserSettings

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

        guard !name.isEmpty else {
            errorMessage = "Empty name not accepted"
            return
        }

        let userId = try? storageManager.addUser(name: name) { err in
            if err != nil {
                assertionFailure()
                return
            }
        }

        guard let receivedUserId = userId else {
            assertionFailure()
            return
        }

        UserDefaults.standard.set(receivedUserId, forKey: "userId")
        settings.userId = userId
    }

}
