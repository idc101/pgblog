require 'rubygems'
require 'sinatra'
require 'sinatra/reloader'
require 'erb'
require 'mongo'
require 'date'
require 'maruku'
require 'uri'

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
  posts = coll.find().sort( { :date => -1 } ).limit(4)
  @title = "Professional Geek Coding Blog"
  erb :index, :locals => { :posts => posts }
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

helpers do
  def markdown(text)
    Maruku.new(text).to_html()
  end
end


