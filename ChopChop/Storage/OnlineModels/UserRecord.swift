//
//  UserRecord.swift
//  ChopChop
//
//  Created by Cao Wenjie on 1/4/21.
//
import FirebaseFirestoreSwift

struct UserRecord {
    @DocumentID var userId: String?
    private(set) var name: String
    private(set) var friendId: [String]
}

extension UserRecord: Codable {
}
