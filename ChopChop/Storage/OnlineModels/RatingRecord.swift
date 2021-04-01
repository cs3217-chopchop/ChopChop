//
//  RatingRecord.swift
//  ChopChop
//
//  Created by Cao Wenjie on 31/3/21.
//
import FirebaseFirestore
import FirebaseFirestoreSwift

// remove
struct RatingRecord {
    @DocumentID var id: String?
    private let userId: String
    private let recipeId: String
    private let rating: RatingScore

    init(userId: String, recipeId: String, rating: RatingScore) {
        self.userId = userId
        self.recipeId = recipeId
        self.rating = rating
    }
}

extension RatingRecord: Codable {
}
