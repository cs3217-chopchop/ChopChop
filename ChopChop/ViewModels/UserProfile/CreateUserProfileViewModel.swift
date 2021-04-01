import Combine
import Foundation
import UIKit

// only displayed on first login ( check if local db has user name )
final class CreateUserProfileViewModel: ObservableObject {

    @Published var name: String = ""
    private let storageManager = StorageManager()
    @Published var errorMessage = ""

    init() {
    }

    func onClick() {
        guard USER_ID == nil else {
            assertionFailure()
        }

        guard let newUser = try? User(name: name) else {
            errorMessage = "Empty name not accepted"
            return
        }
        guard let userId = try storageManager.createUser(user: newUser) else {
            assertionFailure()
        }
        UserDefaults.standard.set(userId, forKey: "userId")
    }

}
