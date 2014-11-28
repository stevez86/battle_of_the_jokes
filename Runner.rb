require_relative 'model'

parser = CSVParser.new(filename: "jokes.csv")

parser.print_CSV
