import Combine
import Foundation
import UIKit

/**
 Represents a view model for the view of the initial user profile creation.
 */
final class CreateUserProfileViewModel: ObservableObject {
    /// Form fields
    @Published var name: String = ""

    /// Error fields
    @Published var errorMessage = ""

    private let settings: UserSettings
    private let storageManager = StorageManager()

    init(settings: UserSettings) {
        self.settings = settings
    }

    /**
     Handles the submission of the user profile creation form.
     */
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
