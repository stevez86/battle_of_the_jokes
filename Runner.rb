require_relative 'model'

game = Controller.new(filename: "jokes.csv")

game.run!

# game.save_jokes
