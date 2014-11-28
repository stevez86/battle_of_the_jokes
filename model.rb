
require 'csv'

class JokeList
  def initialize(args)

  end


end






class Joke
  def initialize(args)
    @joke_string = args.fetch(:joke_string)


  end


end

class CSVParser
  def initialize(args)
    @filename = args.fetch(:filename, "jokes.csv")
    @csv = CSV.read(@filename)
  end

  def print_CSV
    p @csv
  end

end


