require_relative 'model.rb'
require_relative 'view.rb'

class Controller
  #start the program/app
  def self.start(filename)

    @filename = filename
    @parser = CSVParser.new(filename: @filename)

    joke_list = JokeList.new(@parser.load_jokes)

    loop do
      args = View.menu
      if args != nil
        selection = args.shift
        if args.empty?
          joke_list.send(selection)
          @parser.save_jokes(joke_list.jokes)
        else
          joke_list.send(selection, args)
          @parser.save_jokes(joke_list.jokes)
        end
      end
    end
  end
end