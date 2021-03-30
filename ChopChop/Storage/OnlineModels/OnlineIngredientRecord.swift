//
//  OnlineIngredientRecord.swift
//  ChopChop
//
//  Created by Cao Wenjie on 27/3/21.
//
import FirebaseFirestore

struct OnlineIngredientRecord {
    var name: String
    var quantity: QuantityRecord
}

extension OnlineIngredientRecord: Codable {
}
