//
//  NetworkDatabase.swift
//  ChopChop
//
//  Created by Cao Wenjie on 27/3/21.
//

protocol NetworkDatabase {

    func publishRecipe(recipeDetails: Recipe) -> Int64
    func removeOnlineRecipe(onlineRecipeId: Int64) -> Int64
    func updateOnlineRecipe(updateDetails: Recipe)
    func fetchOnlineRecipeByIds(onlineRecipeIds: [Int64]) -> [OnlineRecipe]
    func fetchOnlineRecipeByUser(userIds: [Int64]) -> [OnlineRecipe]
    func addOnlineRecipeRating(onlineRecipeId: Int64, rating: RecipeRating)
    
    func createNewUser(username: String) -> Int64
    func addFollowee(userId: Int64)
}
