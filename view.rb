class View

  def self.menu
    #accept user input
    puts "add, vote, or rankings?"
    menu_option = gets.chomp # or ARGV
    case menu_option
    when "add"
      [:add, add]
    when "vote" #to get 2 jokes and vote
      [:vote, vote]
    when "rankings" #print list of rankings
      [:rankings]
    end
  end

  def self.add
    puts "Enter your joke:"
    joke = gets.chomp
    return joke
  end

  def self.vote
    #retrieve 2 jokes
    puts "1. joke1"
    puts "2. joke2"
    puts "Enter '1' or '2' to vote on which joke is funnier"
    user_vote = gets.chomp
    return user_vote
  end

end
