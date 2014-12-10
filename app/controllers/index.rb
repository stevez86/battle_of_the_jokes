get '/' do

  @jokes = Joke.select_jokes_for_battle

  erb :view
end


post '/'


get '/top' do


  erb :view
end