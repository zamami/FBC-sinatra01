require 'sinatra'
require 'sinatra/reloader'
require 'pg'
# require 'pg'
require 'json'

# client = PG::connect(
#   :host => "localhost",
#   :user => ENV.fetch("USER", "###"), :password => "",
#   :dbname => "###",
# )

# トップ画面
get '/' do
  notes = Dir.glob('public/notes/*') # ファイル名を全て取得
  @notes = notes.map { |file| open(file) { |data| JSON.load(data) } }
  erb :index
end

post '/' do
  time = Time.now.strftime('%Y%m%d_%H_%M_%S') # メモごとにファイルを保存
  File.open("public/notes/#{time}_note.json", 'w') do |file|
    hash = { 'time' => time, 'title' => params[:title], 'content' => params[:contents] }
    JSON.dump(hash, file)
  end
  notes = Dir.glob('public/notes/*') # ファイル名を全て取得
  @notes = notes.map { |file| open(file) { |data| JSON.load(data) } }
  erb :index
end

get '/new' do
  erb :form
end

get '/:id' do
  notes = Dir.glob('public/notes/*') # ファイル名を全て取得
  @notes = notes.map { |file| open(file) { |data| JSON.load(data) } }
  erb :show
end

get '/:id/edit' do
end

patch '/:id' do
end

delete '/:id' do
end
