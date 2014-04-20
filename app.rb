require 'rubygems'
require 'sinatra'
require 'sinatra/reloader'
require 'erb'
require 'mongo'
require 'date'
require 'maruku'

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

get '/posts/:url' do
  post = coll.find_one("url" => params["url"])
  erb :index, :locals => { :posts => [ post ] }
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


