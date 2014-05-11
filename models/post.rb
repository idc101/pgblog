require 'mongo'

class Post
  attr_accessor :id, :title, :url, :date, :tags, :text
end

def hash_to_post(hash)
  post = Post.new
  post.title= hash['title']
  post.url= hash['url']
  post.date= hash['date']
  post.text= hash['text']
  post.tags= hash['tags']
  post
end

def post_to_hash(post)
  hash = {
  'title' => post.title,
  'url' => post.url,
  'date' => post.date,
  'text' => post.text,
  'tags' => post.tags
  }
  hash
end

def params_to_post(params)
  post = Post.new
  post.title = params[:title]
  post.url = params[:url]
  post.text = params[:text]
  post.date = Time.parse(params[:date]).utc
  post.tags = params[:tags].split(',').map(&:strip)
  post
end

def save_post(db, post)
  db['posts'].insert post_to_hash(post)
end

def get_by_url(db, url)
  post_data = db['posts'].find_one("url" => url)
  hash_to_post post_data
end

def get_by_tag(db, tag)
  posts = db['posts'].find("tags" => tag).map { |pd| hash_to_post pd }
  posts
end

def get_recent_posts(db, start)
  posts = db['posts'].find().sort( { :date => -1 } ).skip(start).limit(4).map { |pd| hash_to_post pd }
  posts
end
