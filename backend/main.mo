import Bool "mo:base/Bool";
import Hash "mo:base/Hash";
import Iter "mo:base/Iter";

import Array "mo:base/Array";
import HashMap "mo:base/HashMap";
import Nat "mo:base/Nat";
import Text "mo:base/Text";
import Result "mo:base/Result";
import Int "mo:base/Int";

actor {
  type Recipe = {
    id: Nat;
    title: Text;
    ingredients: [Text];
    instructions: Text;
    upvotes: Int;
    downvotes: Int;
  };

  stable var recipeStore : [(Nat, Recipe)] = [];
  var recipeCounter : Nat = 0;
  var recipes = HashMap.HashMap<Nat, Recipe>(0, Nat.equal, Nat.hash);

  system func preupgrade() {
    recipeStore := Iter.toArray(recipes.entries());
  };

  system func postupgrade() {
    recipes := HashMap.fromIter<Nat, Recipe>(recipeStore.vals(), recipeStore.size(), Nat.equal, Nat.hash);
    if (recipeStore.size() > 0) {
      recipeCounter := recipeStore[recipeStore.size() - 1].0 + 1;
    };
  };

  public func addRecipe(title: Text, ingredients: [Text], instructions: Text) : async Result.Result<Nat, Text> {
    let id = recipeCounter;
    let newRecipe : Recipe = {
      id = id;
      title = title;
      ingredients = ingredients;
      instructions = instructions;
      upvotes = 0;
      downvotes = 0;
    };
    recipes.put(id, newRecipe);
    recipeCounter += 1;
    #ok(id)
  };

  public query func getRecipe(id: Nat) : async Result.Result<Recipe, Text> {
    switch (recipes.get(id)) {
      case (null) { #err("Recipe not found") };
      case (?recipe) { #ok(recipe) };
    }
  };

  public query func getAllRecipes() : async [Recipe] {
    Iter.toArray(recipes.vals())
  };

  public func updateRating(id: Nat, isUpvote: Bool) : async Result.Result<(), Text> {
    switch (recipes.get(id)) {
      case (null) { #err("Recipe not found") };
      case (?recipe) {
        let updatedRecipe = if (isUpvote) {
          { recipe with upvotes = recipe.upvotes + 1 }
        } else {
          { recipe with downvotes = recipe.downvotes + 1 }
        };
        recipes.put(id, updatedRecipe);
        #ok()
      };
    }
  };
}
