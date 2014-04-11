require 'rubygems'
require 'sinatra'
require 'sinatra/reloader'
require 'erb'
require 'mongo'
require 'date'

include Mongo

client = MongoClient.new # defaults to localhost:27017
db = client['pgblog-db']
coll = db['posts']

get '/' do
  posts = coll.find
  
  erb :index, :locals => { :posts => posts }
end

get '/new' do
  erb :new
end

post '/new' do
  title = params[:title]
  url = params[:url]
  text = params[:text]
  date = Date.parse(params[:date]).iso8601
  post = {
      "title" => title,
      "url" => url,
      "date" => date,
      "text" => text
  }
  
  coll.insert(post)
  erb :index, :locals => { :post => post }
end
