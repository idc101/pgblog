require 'rubygems'
require 'sinatra'
require 'sinatra/reloader'
require 'haml'
require 'mongo'

include Mongo

client = MongoClient.new # defaults to localhost:27017
db = client['pgblog-db']
coll = db['posts']

get '/' do
  post = coll.find_one
  
  haml :index, :locals => { :post => post }
end

get '/' do
  haml :index
end

get '/new' do
  haml :new
end

post '/new' do
  title = params[:title]
  url = params[:url]
  text = params[:text]
  post = {
      "title" => title,
      "url" => url,
      "text" => text
  }
  
  coll.insert(post)
  haml :index, :locals => { :post => post }
end
