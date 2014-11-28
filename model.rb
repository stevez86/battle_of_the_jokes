
require 'csv'

class JokeList #model
  def initialize(args = {})
    @csv = args.fetch(:csv)
    @jokes = []
    @headers = []

  end

  def add_joke(string, wins=0, battles=0)

  end

  def delete_joke
  end


  def get_joke_battle
  end

  def sort
  end

  def set_list(list)
    @jokes = list
  end

  def get_jokes_by_rank
  end

  def print_jokes
    @jokes.each {|joke| puts joke}
  end

end


class Joke
  attr_reader :joke_string, :num_wins, :num_battles

  def initialize(args = {})
    @joke_string = args.fetch(:joke, '')
    @num_wins = args.fetch(:wins, 0).to_i
    @num_battles = args.fetch(:battles, 0).to_i
  end

  def set_joke(new_joke)
    @joke_string = new_joke
  end

  def to_s
    "#{@joke_string} wins: #{@num_wins} battles: #{@num_battles}"
  end
end

class CSVParser
  def initialize(args = {})
    @filename = args.fetch(:filename, "jokes.csv")
    @csv = CSV.read(@filename)
  end

  def load_jokes

    jokes = []

    @headers = @csv.shift

    @csv.each do |line|

      joke_args = {}
      @headers.each_with_index do |header,index|
        joke_args[header.to_sym] = line[index]
      end
      jokes << Joke.new(joke_args)
    end

    return jokes
  end

  def get_csv
    @csv
  end

  def save_jokes
    CSV.open(@filename, "wb", :quote_char => "\x00") do |csv|
      @jokes.each do |joke|
        input = [joke.joke_string, joke.num_wins.to_s, joke.num_battles.to_s]
        p input
        csv << input
        # p csv
      end
    end
  end

end

class Controller
  def initialize(args = {})
    @filename = args.fetch(:filename)
    parser = CSVParser.new(@filename)
    csv = parser.get_csv
    @joke_list = JokeList.new()
  end

  def run!
    @joke_list.set_list(@parser.load_jokes)




    @parser.save_jokes(@joke_list.get_list)
  end

  def print_jokes
    @joke_list.print_jokes
  end

  def save_jokes
    @parser.save_jokes
  end

end
