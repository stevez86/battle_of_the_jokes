# require_relative 'controller.rb'
class View

  def self.menu
    #accept user input
    clear_screen
    puts "Input commands: add, vote, jokes, or exit?"
    menu_option = gets.chomp # or ARGV
    case menu_option
    when "add"
      [:add_joke, add]
    when "delete"
      [:delete_joke, delete]
    when "vote" #to get 2 jokes and vote
      [:start_joke_battle]
    when "jokes" #print list of rankings
      clear_screen
      [:print_jokes]
    when "exit"
      exit
    else
      puts "Please enter a valid command."
      return
    end
  end

  def self.add
    clear_screen
    puts "Enter your joke:"
    joke = gets.chomp
    # p joke
    return joke
  end

  def self.loading
    print "Binary searching the ENTIRE official worldwide joke database \nsearching."
    25.times do
      sleep(0.1)
      print "."
    end
  end

  def self.vote(two_jokes)
    #input: 2 jokes
    #output: user's vote (either 1 or 2)
    #retrieve 2 jokes

    # loading
    clear_screen
    puts "-"*50
    puts "1. #{two_jokes.first}"
    puts "-"*50
    puts "2. #{two_jokes.last}"
    puts "-"*50
    puts "Vote '1' or '2' to vote on which joke is funnier:"
    user_vote = gets.chomp.to_i
    #manipulate winner joke +1

    if user_vote == 2
      return two_jokes = [two_jokes[1],two_jokes[0]]
    elsif user_vote == 1
      return two_jokes
    else
      return nil
    end
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

  def self.clear_screen
    print "\e[2J"
    print "\e[H"
  end

end
