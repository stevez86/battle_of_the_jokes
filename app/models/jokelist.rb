class JokeList #model
  attr_accessor :jokes

  def initialize(jokes = [])
    @jokes = jokes
    @headers = []
    initialize_ids
  end

  def initialize_ids
    jokes_with_no_id = @jokes.select{|joke| joke.id == nil}
    jokes_with_no_id.each {|joke| joke.id = next_id}
  end

  def next_id
    next_id = -1
    initialized_jokes = @jokes.select{|joke| joke.id != nil}
    next_id = initialized_jokes.max_by{|joke| joke.id}.id if initialized_jokes != []
    # @jokes.each{|joke| next_id = joke.id if joke.id > next_id}
    next_id += 1
  end

  def start_joke_battle
    return_pair = View.vote(select_jokes_for_battle)
    update_rankings(return_pair[0],return_pair[1]) unless return_pair.nil?
  end

  def select_jokes_for_battle

    battle_range = 200

    joke_type = [:alive,:battle_free].sample

    joke_for_battle = get_jokes(joke_type).sample
    # joke_for_battle = get_jokes(:id,"17") TODO - remove this after testing specific id
    joke_for_battle = get_jokes(:alive).sample if joke_for_battle.nil?


    eligible_opponents = get_jokes(:all).select do |joke|
      joke.ranking > joke_for_battle.ranking - battle_range &&
      joke.ranking < joke_for_battle.ranking + battle_range
    end

    while eligible_opponents.size < 5
      # puts "expanding range..."
      battle_range += 50
      eligible_opponents = get_jokes(:alive).select do |joke|
        joke.ranking > joke_for_battle.ranking - battle_range &&
        joke.ranking < joke_for_battle.ranking + battle_range
      end
    end

    opponent = eligible_opponents.sample

    while opponent == joke_for_battle
      opponent = eligible_opponents.sample
    end

    # puts "#{joke_type}"
    # puts "joke1: #{joke_for_battle} #{joke_for_battle.ranking}"
    # puts "joke2: #{opponent} #{joke_for_battle.ranking}"
    # View.user_pause

    return [joke_for_battle,opponent].shuffle
  end

  def get_jokes(type, *args)

    # puts "args #{args}"

    case type
    when :alive       then return @jokes.select { |joke| joke.dead == false && joke.immortal == false}
    when :dead        then return @jokes.select { |joke| joke.dead == true }
    when :immortal    then return @jokes.select { |joke| joke.immortal == true}
    when :battle_free then return @jokes.select { |joke| joke.battles == 0}
    when :all         then return @jokes
    when :id          then return @jokes.select { |joke| joke.id == args[0]}.first
    end
  end

  def kill_bad_jokes
    jokes_to_kill = @jokes.select{ |joke| joke.battles > 10 && joke.ranking < 400}
    jokes_to_kill.each { |joke| joke.dead = true }
  end

  def immortalize_good_jokes
    jokes_to_immortalize = @jokes.select{ |joke| joke.battles > 10 && joke.ranking > 1200}
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
    winner.ranking += winner.kfact * (1 - e_winner)
    winner.ranking = 100.0 if winner.ranking < 100
    winner.opponent_ids << loser.id

    #update loser
    loser.battles += 1
    loser.ranking += - loser.kfact * e_loser
    loser.ranking = 100.0 if loser.ranking < 100
    loser.opponent_ids << winner.id

    puts "\nNew winner ranking: #{winner.ranking}"
    puts "New loser ranking: #{loser.ranking}"

    #sort list
    sort!
    kill_bad_jokes
    immortalize_good_jokes
    View.user_pause
  end

  def calc_q(joke)
    10 ** (joke.ranking / 400.0)
  end

  def sort!
    @jokes = @jokes.sort_by! {|joke| -joke.ranking}
  end

  def print_jokes
    sort!

    kill_bad_jokes
    immortalize_good_jokes

    jokes_order = [:immortal, :alive, :dead, :battle_free]

    View.clear_screen

    jokes_order.each do |list|

      if get_jokes(list).size > 0
        puts "#{list.capitalize} jokes:"
        get_jokes(list).each_with_index {|joke, index| puts "#{index+1}. #{joke} [rank: #{joke.ranking.round(2)}, #{joke.wins}/#{joke.battles}]"}
        puts
      end
    end

    View.user_pause
  end
end
