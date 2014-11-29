
require 'csv'

class JokeList #model
  def initialize
    @jokes = []
    @headers = []
  end

  def add_joke(string_array, wins=0, battles=0)
    p string_array[0]
    @jokes << Joke.new(joke_string: string_array[0], wins: wins, battles: battles)
  end

  def start_joke_battle
    return_pair = View.vote(@jokes.shuffle.slice(0,2))
    return_pair[0].win!
    return_pair[1].lose!
  end

  def sort!
    @jokes = @jokes.sort_by! {|joke| joke.num_wins}.reverse
  end

  def set_list(list)    #only ran when loaded
    @jokes = list
  end

  def get_list
    @jokes
  end

  def print_jokes
    sort!
    @jokes.each_with_index {|joke, index| puts "#{index+1}. #{joke} [wins: #{joke.num_wins}]"}
    puts "\nPress ENTER to continue"
    gets.chomp
  end
end


class Joke
  attr_reader :joke_string, :num_wins, :num_battles

  def initialize(args = {})
    @joke_string = args.fetch(:joke_string, '')
    @num_wins = args.fetch(:wins, 0).to_i
    @num_battles = args.fetch(:battles, 0).to_i
  end

  def set_joke(new_joke)
    @joke_string = new_joke
  end

  def to_s
    "#{@joke_string}"#{}" wins: #{@num_wins} battles: #{@num_battles}"
  end

  def win!
    @num_wins += 1
    @num_battles += 1
  end

  def lose!
    @num_battles += 1
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

  def save_jokes(jokes)
    CSV.open(@filename, "w") do |csv|
      headers = ["joke_string","wins","battles"]
      csv << headers
      jokes.each do |joke|
        input = [joke.joke_string, joke.num_wins.to_s, joke.num_battles.to_s]
        csv << input
      end
    end
  end

end
