require_relative 'model'
require_relative 'controller'

game = Controller.new(filename: "jokes.csv")

game.run!

# game.save_jokes
