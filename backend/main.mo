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

  func initializeRecipes() {
    let initialRecipes : [Recipe] = [
      { id = 0; title = "Classic Cheese and Onion Pie"; ingredients = ["Shortcrust pastry", "Cheddar cheese", "Onions", "Eggs", "Milk", "Salt", "Pepper"]; instructions = "1. Preheat oven. 2. Sauté onions. 3. Mix with grated cheese, eggs, and milk. 4. Pour into pastry case. 5. Bake until golden."; upvotes = 0; downvotes = 0 },
      { id = 1; title = "Cheese and Onion Quiche"; ingredients = ["Pie crust", "Gruyere cheese", "Caramelized onions", "Eggs", "Cream", "Thyme", "Nutmeg"]; instructions = "1. Blind bake crust. 2. Layer cheese and onions. 3. Pour over egg and cream mixture. 4. Bake until set."; upvotes = 0; downvotes = 0 },
      { id = 2; title = "Cheese and Onion Crisps"; ingredients = ["Potatoes", "Vegetable oil", "Cheese powder", "Onion powder", "Salt"]; instructions = "1. Slice potatoes thinly. 2. Fry until crisp. 3. Toss with cheese and onion seasoning."; upvotes = 0; downvotes = 0 },
      { id = 3; title = "Cheese and Onion Soup"; ingredients = ["Onions", "Butter", "Flour", "Beef stock", "Cheddar cheese", "Bread", "Thyme"]; instructions = "1. Caramelize onions. 2. Make roux and add stock. 3. Simmer. 4. Add cheese. 5. Serve with cheesy toast."; upvotes = 0; downvotes = 0 },
      { id = 4; title = "Cheese and Onion Stuffed Mushrooms"; ingredients = ["Large mushrooms", "Cream cheese", "Cheddar cheese", "Green onions", "Garlic", "Breadcrumbs"]; instructions = "1. Remove mushroom stems. 2. Mix cheeses, onions, and garlic. 3. Stuff mushrooms. 4. Top with breadcrumbs. 5. Bake until golden."; upvotes = 0; downvotes = 0 }
    ];
    
    for (recipe in initialRecipes.vals()) {
      recipes.put(recipe.id, recipe);
      recipeCounter += 1;
    };
  };

  system func preupgrade() {
    recipeStore := Iter.toArray(recipes.entries());
  };

  system func postupgrade() {
    recipes := HashMap.fromIter<Nat, Recipe>(recipeStore.vals(), recipeStore.size(), Nat.equal, Nat.hash);
    if (recipeStore.size() > 0) {
      recipeCounter := recipeStore[recipeStore.size() - 1].0 + 1;
    } else {
      initializeRecipes();
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
