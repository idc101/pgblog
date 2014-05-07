require 'rubygems'
require 'sinatra'
require 'sinatra/reloader'
require 'erb'
require 'mongo'
require 'date'
require 'maruku'
require 'uri'
require 'json'
require 'rest-client'

enable :sessions

$stdout.sync = true

puts "hello"

set :session_secret, '2be0d9ad-30a6-410d-a16a-3011dbedd2e8'

def get_connection
  return @db_connection if @db_connection
  #export MONGOHQ_URL=mongodb://localhost:27017/pgblog-db
  db = URI.parse(ENV['MONGOHQ_URL'])
  db_name = db.path.gsub(/^\//, '')
  @db_connection = Mongo::Connection.new(db.host, db.port).db(db_name)
  @db_connection.authenticate(db.user, db.password) unless (db.user.nil? || db.user.nil?)
  @db_connection
end

db = get_connection

#client = MongoClient.new # defaults to localhost:27017
#db = client['pgblog-db']

coll = db['posts']


get '/' do
  puts "hello"
  start = params.has_key?("start") ? params["start"].to_i : 0
  posts = coll.find().sort( { :date => -1 } ).skip(start).limit(4)
  @title = "Professional Geek Coding Blog"
  erb :index, :locals => { :posts => posts, :start => start }
end

get '/new' do
  @title = "Professional Geek Coding Blog"
  erb :new
end

get '/edit/:url' do
  @title = "Professional Geek Coding Blog"
  post = coll.find_one("url" => params["url"])
  erb :new, :locals => { :post => post }
end

get '/posts/:url' do
  @title = "Professional Geek Coding Blog"
  post = coll.find_one("url" => params["url"])
  erb :index, :locals => { :posts => [ post ] }
end

post '/preview' do
  Maruku.new(params[:text]).to_html()
end

post '/new' do
  if session[:email].nil?
    halt 500, 'Please log in!'
  end
  user = db['users'].find_one("email" => session[:email])
  if user.nil?
    halt 500, 'User not allowed to post!'
  end
  title = params[:title]
  url = params[:url]
  text = params[:text]
  date = Time.parse(params[:date]).utc
  post = {
      "title" => title,
      "url" => url,
      "date" => date,
      "text" => text
  }
  
  coll.insert(post)

  redirect "/posts/#{url}"
end


post "/auth/login" do
  # check assertion with a request to the verifier
  response = nil
  puts "#{ENV['SITE_URL']}:#{request.port}"
  if params[:assertion]
    restclient_url = "https://verifier.login.persona.org/verify"
    restclient_params = {
      :assertion => params["assertion"],
      :audience  => "#{ENV['SITE_URL']}:#{request.port}", # use your website's URL here.
    }
    response = JSON.parse(RestClient::Resource.new(restclient_url, :verify_ssl => true).post(restclient_params))
  end

  # create a session if assertion is valid
  if response["status"] == "okay"
    session[:email] = response["email"]
    response.to_json
  else
    {:status => "error"}.to_json
  end
end

get "/auth/logout" do
   session[:email] = nil
   redirect "/"
end


helpers do
  def markdown(text)
    Maruku.new(text).to_html()
  end
  def login?
    !session[:email].nil?
  end
end


