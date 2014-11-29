require_relative 'model.rb'
require_relative 'view.rb'

class Controller
  #start the program/app
  def self.start(filename)

    @filename = filename
    @parser = CSVParser.new(filename: @filename)

    joke_list = JokeList.new


    joke_list.set_list(@parser.load_jokes) ## LOADING


    loop do
      args = View.menu
      if args != nil
        selection = args.shift
        if args.empty?
          joke_list.send(selection)
          @parser.save_jokes(joke_list.get_list)
        else
          joke_list.send(selection, args)
          @parser.save_jokes(joke_list.get_list)
        end
      end
    end
  end
end

Controller.start('jokes.csv')
