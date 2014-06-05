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
    results = connection.exec_params('SELECT id, name, instructions, description FROM recipes WHERE id = $1', [num])
    connection.close
    the_recipe = Recipe.new(results[0]["id"], results[0]["name"], results[0]["instructions"], results[0]["description"])
    the_recipe
  end

  def ingredients
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


