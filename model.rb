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
    return_pair = View.vote(select_for_joke_battle)
    update_rankings(return_pair[0],return_pair[1]) unless return_pair.nil?
    kill_bad_jokes
  end

  def select_for_joke_battle
    alive_jokes.sample(2)
  end

  def alive_jokes
    @jokes.select { |joke| joke.dead == false }
  end

  def dead_jokes
    @jokes.select { |joke| joke.dead == true }
  end

  def kill_bad_jokes
    jokes_to_kill = @jokes.select{ |joke| joke.battles > 10 && joke.ranking < 300}
    jokes_to_kill.each { |joke| joke.dead = true }
  end

  def update_rankings(winner,loser)
    q_winner = calc_q(winner)
    q_loser = calc_q(loser)

    e_winner = q_winner / (q_winner + q_loser)
    e_loser = q_loser / (q_winner + q_loser)

    puts "\nWinner ranking: #{winner.ranking}"
    puts "Loser ranking: #{loser.ranking}"

    #update winner
    winner.wins += 1
    winner.battles += 1
    winner.sum_of_opponents_ranking += loser.ranking
    winner.ranking = winner.ranking + winner.kfact * (1 - e_winner)
    winner.ranking = 100.0 if winner.ranking < 100

    #update loser
    loser.battles += 1
    loser.sum_of_opponents_ranking += loser.ranking
    loser.ranking = loser.ranking + loser.kfact * (0 - e_loser)
    loser.ranking = 100.0 if loser.ranking < 100

    puts "\nNew winner ranking: #{winner.ranking}"
    puts "New loser ranking: #{loser.ranking}"

    #sort list
    sort!
    pause
  end

  def calc_q(joke)
    10 ** (joke.ranking / 400.0)
  end

  def sort!
    @jokes = @jokes.sort_by! {|joke| joke.ranking}.reverse
  end

  def set_list(list)    #only ran when loaded
    @jokes = list
  end

  def get_list
    @jokes
  end

  def print_jokes
    sort!
    puts "Top jokes:"
    alive_jokes.each_with_index {|joke, index| puts "#{index+1}. #{joke} [ranking: #{joke.ranking.round(2)}, wins: #{joke.wins}, battles: #{joke.battles}]"}

    puts "\nDead jokes:" if dead_jokes != []
    dead_jokes.each_with_index {|joke, index| puts "#{index+1}. #{joke} [ranking: #{joke.ranking.round(2)}, wins: #{joke.wins}, battles: #{joke.battles}]"}
    pause
  end

  def pause
    puts "\nPress ENTER to continue..."
    gets.chomp
  end
end


class Joke
  attr_accessor :joke_string, :wins, :battles, :ranking, :sum_of_opponents_ranking, :kfact, :dead

  def initialize(args = {})
    @joke_string = args.fetch(:joke_string, '')
    @wins = args.fetch(:wins, 0).to_i
    @battles = args.fetch(:battles, 0).to_i
    @ranking = args.fetch(:ranking, 100).to_f
    @sum_of_opponents_ranking = args.fetch(:sum_of_opponents_ranking, 0).to_f
    @dead = args.fetch(:dead, false) == "true"
    @kfact = 800.0 / (1 + @battles)
  end

  def to_s
    "#{@joke_string}"
  end
end

class CSVParser
  def initialize(args = {})
    @filename = args.fetch(:filename, "jokes.csv")
    @csv = CSV.read(@filename)
  end

  def load_jokes
    jokes = []
    @headers = @csv.shift.map &:to_sym
    reset = false # if true, resets all jokes

    @csv.each do |line|

      if line.size == @headers.size && !reset
        joke_args = Hash[@headers.zip(line)]
      else
        p joke_args = {joke_string: line[0]}
      end

      jokes << Joke.new(joke_args)
    end

    return jokes
  end

  def save_jokes(jokes)
    CSV.open(@filename, "w") do |csv|

      csv << @headers
      jokes.each do |joke|
        csv << [joke.joke_string, joke.wins.to_s, joke.battles.to_s, joke.ranking.to_s, joke.sum_of_opponents_ranking.to_s, joke.dead.to_s]
      end
    end
  end
end
