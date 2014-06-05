require 'pg'
require 'pry'

class Recipe
  attr_reader :id, :name, :instructions, :description

  def initialize(id, name, instructions, description)
    @id = id
    @name = name
    @instructions = instructions
    @description = description
  end

  def self.all
  end

  def self.find(num)
    connection = PG.connect(dbname: 'recipes')
    results = connection.exec_params(
      'SELECT recipes.id, recipes.name, recipes.instructions, recipes.description
       FROM recipes WHERE recipes.id = $1', [num])
    connection.close
    if results[0]["description"] != nil && results[0]["instructions"] != nil
      the_recipe = Recipe.new(results[0]["id"], results[0]["name"], results[0]["instructions"], results[0]["description"])
    elsif results[0]["description"] == nil && results[0]["instructions"] != nil
      the_recipe = Recipe.new(results[0]["id"], results[0]["name"], results[0]["instructions"], "This recipe doesn't have a description.")
    elsif results[0]["description"] != nil && results[0]["instructions"] == nil
      the_recipe = Recipe.new(results[0]["id"], results[0]["name"], "This recipe doesn't have any instructions.", results[0]["description"])
    else
      the_recipe = Recipe.new(results[0]["id"], results[0]["name"], "This recipe doesn't have any instructions.", "This recipe doesn't have a description.")
    end
    the_recipe
  end

  def ingredients
    @ingredients = []
    connection = PG.connect(dbname: 'recipes')
    results = connection.exec_params(
      'SELECT ingredients.name FROM recipes JOIN ingredients ON recipes.id = ingredients.recipe_id
       WHERE recipes.id = $1', [self.id])
    connection.close
    ingredients_list = results.to_a
      ingredients_list.each do |ingredient_hash|
        @ingredients << Ingredient.new(ingredient_hash["name"])
      end
    @ingredients
  end
end

def get_recipes
  @recipes = []
  connection = PG.connect(dbname: 'recipes')
  results = connection.exec('SELECT id, name, instructions, description FROM recipes')
  connection.close
  @data = results.to_a
  @data.each do |recipe|
    a_rec = Recipe.new(recipe["id"], recipe["name"], recipe["instructions"], recipe["description"])
    @recipes << a_rec
  end
end

