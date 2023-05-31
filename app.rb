require 'sinatra'
require 'sinatra/reloader'
require 'pg'
require 'json'

helpers do
  def h(text)
    Rack::Utils.escape_html(text)
  end
end

# トップ画面
ID_NUMBER_ADJUSTMENT = 1 # 配列の要素番号とメモの番号のズレを調整
get '/memos' do
  notes = Dir.glob('public/notes/*') # ファイル名を全て取得
  hash_datas = notes.map do |file| # jsonデータをハッシュに変換
    note = File.open(file, 'r')
    note.read
  end
  @notes = hash_datas.map.each_with_index do |file_data, index|
    hash_data = JSON.parse(file_data)
    hash_data['id'] = index + ID_NUMBER_ADJUSTMENT # idの値を１から始まる番号に変換
    hash_data
  end
  erb :index
end

post '/memos' do # 新規メモデータの受け取り
  time = Time.now.strftime('%Y%m%d_%H_%M_%S') # メモごとにファイルを保存
  File.open("public/notes/#{time}_note.json", 'w') do |file| # 新規投稿フォームの内容をjsonに保存
    hash = { 'id' => time, 'title' => params[:title], 'content' => params[:contents] }
    JSON.dump(hash, file)
  end
  notes = Dir.glob('public/notes/*') # ファイル名を全て取得
  hash_datas = notes.map do |file| # jsonデータをハッシュに変換
    note = File.open(file, 'r')
    note.read
  end
  @notes = hash_datas.map.each_with_index do |file_data, index|
    hash_data = JSON.parse(file_data)
    hash_data['id'] = index + ID_NUMBER_ADJUSTMENT # idの値を１から始まる番号に変換
    hash_data
  end
  redirect to('/memos')
end

get '/memos/new' do # 新規登録
  erb :form
end

get '/memos/:id' do # 詳細画面
  notes = Dir.glob('public/notes/*') # ファイル名を全て取得
  hash_datas = notes.map do |file| # jsonデータをハッシュに変換
    note = File.open(file, 'r')
    note.read
  end
  @notes = hash_datas.map.each_with_index do |file_data, index|
    hash_data = JSON.parse(file_data)
    hash_data['id'] = index + ID_NUMBER_ADJUSTMENT # idの値を１から始まる番号に変換
    hash_data
  end
  erb :show
end

delete '/memos/:id' do
  delete_note = Dir.glob('public/notes/*')[params[:id].to_i - ID_NUMBER_ADJUSTMENT] # 削除するファイル名を取得
  File.delete(delete_note)
  redirect to('/memos')
end

get '/memos/:id/edit' do
  note = Dir.glob('public/notes/*')[params[:id].to_i - ID_NUMBER_ADJUSTMENT] # ファイル名を全て取得
  edit_note = File.open(note, 'r+').read
  @edit_note = JSON.parse(edit_note)
  erb :edit_memo
end

patch '/memos/:id' do
  notes = Dir.glob('public/notes/*')[params[:id].to_i - ID_NUMBER_ADJUSTMENT] # ファイル名を全て取得
  note = File.open(notes).read
  update_note = JSON.parse(note)
  update_note['title'] = params['title']
  update_note['content'] = params['content']
  File.open(note, 'w') { |f| JSON.dump(update_note, f) }
  redirect to('/memos')
end
