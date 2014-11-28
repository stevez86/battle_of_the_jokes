require_relative 'test_model.rb'
require_relative 'view.rb'

class Controller
  #start the program/app
  def self.start
    joke_list = JokeList.new
    args = View.menu
    selection = args.shift
    if args.empty?
      joke_list.send(selection)
    else
      joke_list.send(selection, args)
    end
  end
end

Controller.start
