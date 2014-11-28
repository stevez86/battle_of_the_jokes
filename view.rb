class View

  def self.menu
    #accept user input
    puts "add, vote, rankings, or exit?"
    menu_option = gets.chomp # or ARGV
    case menu_option
    when "add"
      [:add, add]
    when "delete"
      [:delete, delete]
    when "vote" #to get 2 jokes and vote
      [:vote, vote]
    when "rankings" #print list of rankings
      [:rankings]
    when "exit"
      exit
    end
  end

  def self.add
    puts "Enter your joke:"
    joke = gets.chomp
    return joke
  end

  def self.vote(two_jokes)
    #input: 2 jokes
    #output: user's vote (either 1 or 2)
    #retrieve 2 jokes
    joke1 = two_jokes.first
    joke2 = two_jokes.last
    puts "1. #{joke1}"
    puts "2. #{joke2}"
    puts "Enter '1' or '2' to vote on which joke is funnier"
    user_vote = gets.chomp
    return user_vote
  end

  def self.delete
    puts "what would you like to delete?"
    deleted_joke = gets.chomp
    return deleted_joke
  end

  def self.exit
    puts "Thank you for playing."
    Kernel.exit
  end

  def self.rankings
    puts #all the jokes in ranked order
  end

end
