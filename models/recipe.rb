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
    fetch_recipes
    @recipes = []
    @data.each do |rec|
      a_rec = Recipe.new(
        rec['id'], rec['name'], rec['instructions'], rec['description'])
      @recipes << a_rec
    end
    @recipes
  end

  def self.find(num)
    connection = PG.connect(dbname: 'recipes')
    results = connection.exec_params(
      'SELECT id, name, instructions, description
       FROM recipes WHERE recipes.id = $1', [num])
    connection.close
    @path = results[0]
    check_for_nil
  end

  def ingredients
    @ingredients = []
    fetch_ingredients
    @ingredients_list.each do |ingredient_hash|
      @ingredients << Ingredient.new(ingredient_hash['name'])
    end
    @ingredients
  end
end

def fetch_ingredients
  connection = PG.connect(dbname: 'recipes')
  results = connection.exec_params(
    'SELECT ingredients.name FROM recipes JOIN ingredients ON recipes.id = ingredients.recipe_id
     WHERE recipes.id = $1', [id])
  connection.close
  @ingredients_list = results.to_a
end

def fetch_recipes
  connection = PG.connect(dbname: 'recipes')
  results = connection.exec('SELECT id, name, instructions, description FROM recipes')
  connection.close
  @data = results.to_a
end

def check_for_nil
  if !@path['description'].nil? && !@path['instructions'].nil?
    the_recipe = Recipe.new(
      @path['id'], @path['name'], @path['instructions'], @path['description'])
  elsif !@path['description'].nil? && !@path['instructions'].nil?
    the_recipe = Recipe.new(
      @path['id'], @path['name'], @path['instructions'], "This recipe doesn't have a description.")
  elsif !@path['description'].nil? && !@path['instructions'].nil?
    the_recipe = Recipe.new(
      @path['id'], @path['name'], "This recipe doesn't have any instructions.", @path['description'])
  else
    the_recipe = Recipe.new(
      @path['id'], @path['name'], "This recipe doesn't have any instructions.", "This recipe doesn't have a description.")
  end
  the_recipe
end
