import Combine
import Foundation
import UIKit

var USER_ID = UserDefaults.standard.string(forKey: "userId")

final class CreateUserProfileViewModel: ObservableObject {

    @Published var name: String = ""
    private let storageManager = StorageManager()
    @Published var errorMessage = ""

    init() {
    }

    func onClick() {
        guard USER_ID == nil else {
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
        USER_ID = userId
    }

}
