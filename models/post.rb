require 'mongo'

class Post
  attr_accessor :id, :title, :url, :date, :tags, :text
end

def post_data_to_post(post_data)
  post = Post.new
  post.title= post_data['title']
  post.url= post_data['url']
  post.date= post_data['date']
  post.text= post_data['text']
  post.tags= post_data['tags']
  post
end

def params_to_post(params)
  post.title = params[:title]
  post.url = params[:url]
  post.text = params[:text]
  post.date = Time.parse(params[:date]).utc
  post.tags = params[:tags].split(',').map(&:strip)
  post
end

def save_post(db, post)
  db['posts'].insert post
end

def get_by_url(db, url)
  post_data = db['posts'].find_one("url" => url)
  post_data_to_post post_data
end

def get_by_tag(db, tag)
  posts = db['posts'].find("tags" => tag).map { |pd| post_data_to_post pd }
  posts
end

def get_recent_posts(db, start)
  posts = db['posts'].find().sort( { :date => -1 } ).skip(start).limit(4).map { |pd| post_data_to_post pd }
  posts
end
