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
  end

  def select_for_joke_battle

    joke_type = [:alive,:battle_free].sample #2/3 of the time it picks jokes that are battle free, other times 2 random jokes

    jokes_for_battle = get_jokes(joke_type).sample(2)

    # whenever there aren't 2 jokes or if they are the same
    while jokes_for_battle.size < 2 || jokes_for_battle[0].joke_string == jokes_for_battle[1].joke_string
      jokes_for_battle.pop if jokes_for_battle[0].joke_string == jokes_for_battle[1].joke_string
      jokes_for_battle << get_jokes(:alive).sample
    end

    jokes_for_battle
  end

  def get_jokes(type)

    case type
    when :alive then return @jokes.select { |joke| joke.dead == false && joke.immortal == false}
    when :dead then return @jokes.select { |joke| joke.dead == true }
    when :immortal then return @jokes.select { |joke| joke.immortal == true}
    when :battle_free then return @jokes.select { |joke| joke.battles == 0}
    when :all then return @jokes
    end
  end

  def kill_bad_jokes
    jokes_to_kill = @jokes.select{ |joke| joke.battles > 2 && joke.ranking < 300}
    jokes_to_kill.each { |joke| joke.dead = true }
  end

  def immortalize_good_jokes
    jokes_to_immortalize = @jokes.select{ |joke| joke.battles > 2 && joke.ranking > 600}
    jokes_to_immortalize.each { |joke| joke.immortal = true }
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
    winner.ranking += winner.kfact * (1 - e_winner)
    winner.ranking = 100.0 if winner.ranking < 100

    #update loser
    loser.battles += 1
    loser.sum_of_opponents_ranking += loser.ranking
    loser.ranking +=  loser.kfact * (0 - e_loser)
    loser.ranking = 100.0 if loser.ranking < 100

    puts "\nNew winner ranking: #{winner.ranking}"
    puts "New loser ranking: #{loser.ranking}"

    #sort list
    sort!
    kill_bad_jokes
    immortalize_good_jokes
    user_pause
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

    kill_bad_jokes
    immortalize_good_jokes

    jokes_order = [:immortal, :alive, :dead]

    View.clear_screen

    jokes_order.each do |list|

      if get_jokes(list).size > 0
        puts "#{list.capitalize} jokes:"
        get_jokes(list).each_with_index {|joke, index| puts "#{index+1}. #{joke} [ranking: #{joke.ranking.round(2)}, wins: #{joke.wins}, battles: #{joke.battles}]"}
        puts
      end
    end

    user_pause
  end

  def user_pause
    puts "\nPress ENTER to continue..."
    gets.chomp
  end
end


class Joke
  attr_accessor :joke_string, :wins, :battles, :ranking, :sum_of_opponents_ranking, :dead, :immortal

  def initialize(args = {})
    @joke_string = args.fetch(:joke_string, '')
    @wins = args.fetch(:wins, 0).to_i
    @battles = args.fetch(:battles, 0).to_i
    @ranking = args.fetch(:ranking, 100).to_f
    @sum_of_opponents_ranking = args.fetch(:sum_of_opponents_ranking, 0).to_f
    @dead = args.fetch(:dead, false) == "true"
    @immortal = args.fetch(:immortal, false) == "true"
    @kfact = 800.0 / (1 + @battles)
  end

  def kfact
    800.0 / (1 + @battles).to_f
  end

  def to_s
    "#{@joke_string} #{@ranking.round(2)}"
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
        joke_args = {joke_string: line.first}
      end

      jokes << Joke.new(joke_args)
    end

    jokes
  end

  def save_jokes(jokes)
    CSV.open(@filename, "w") do |csv|

      csv << @headers
      jokes.each do |joke|
        csv << [joke.joke_string, joke.wins.to_s, joke.battles.to_s, joke.ranking.to_s, joke.sum_of_opponents_ranking.to_s, joke.dead.to_s, joke.immortal.to_s]
      end
    end
  end
end
