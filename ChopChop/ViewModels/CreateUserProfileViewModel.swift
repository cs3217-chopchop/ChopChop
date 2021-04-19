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
            return
        }

        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else {
            errorMessage = "Empty name not accepted"
            return
        }

        try? storageManager.addUser(name: trimmedName) { userId, err in
            guard let userId = userId, err == nil else {
                return
            }
            self.settings.userId = userId
        }
    }
}
