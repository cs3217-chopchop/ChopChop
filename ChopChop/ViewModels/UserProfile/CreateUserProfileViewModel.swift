import Combine
import Foundation
import UIKit

// only displayed on first login ( check if local db has user name )
final class CreateUserProfileViewModel: ObservableObject {

    @Published var name: String = ""

    init() {

    }

    func onClick() {
        // send name to firebase
        // update local also
        
    }

}
