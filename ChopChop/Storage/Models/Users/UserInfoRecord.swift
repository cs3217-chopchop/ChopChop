import FirebaseFirestore
import FirebaseFirestoreSwift

struct UserInfoRecord: InfoRecord {
    @DocumentID var id: String?
    @ServerTimestamp var updatedAt: Date?
    @ServerTimestamp var createdAt: Date? // actually dont need but convention

}
