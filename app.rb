
# rooting
#  トップ画面、メモ作成
# get:/memos
# post:/memos
# get:/new
# get:/books/:id/edit
# get:/books/:id(show)
# patch:/books/:id
# delete:/books/:id

require "sinatra"
require "sinatra/reloader"
require "pg"
require "pg"

# client = PG::connect(
#   :host => "localhost",
#   :user => ENV.fetch("USER", "###"), :password => "",
#   :dbname => "###",
# )

# トップ画面
get "/" do
  erb :index
end

post "/" do
  @memos = []
  @memos << params[:title]
  @memos << params[:contents]
  erb :index
end

get "/new" do
  erb :form
end

get "/books/:id/edit" do

end

get "/books/:id(show)" do
end

patch "/books/:id" do
end

delete "/books/:id" do
end
