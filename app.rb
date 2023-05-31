# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader'
require 'json'
require 'pg'

ID_NUMBER_ADJUSTMENT = 1 # 配列の要素番号とメモの番号のズレを調整
helpers do
  def h(text)
    Rack::Utils.escape_html(text) # XSS対策
  end

  def set_file
    Dir.glob('public/notes/*')[params[:id].to_i - ID_NUMBER_ADJUSTMENT] # 削除するファイル名を取得
  end

  def set_all_files
    files = Dir.glob('public/notes/*') # ファイル名を全て取得
    hash_datas = files.map do |file| # jsonデータをハッシュに変換
      memo = File.open(file, 'r')
      memo.read
    end
    @files = hash_datas.map.each_with_index do |file_data, index|
      hash_data = JSON.parse(file_data)
      hash_data['id'] = index + ID_NUMBER_ADJUSTMENT # idの値を１から始まる番号に変換
      hash_data
    end
  end

  def make_json_file
    time = Time.now.strftime('%Y%m%d_%H_%M_%S') # メモごとにファイルを保存
    File.open("public/notes/#{time}_note.json", 'w') do |file| # 新規投稿フォームの内容をjsonに保存
      hash = { 'id' => time, 'title' => params[:title], 'content' => params[:contents] }
      JSON.dump(hash, file)
    end
  end
end

get '/memos' do # トップ画面
  set_all_files
  erb :index
end

post '/memos' do # 新規メモデータの受け取り
  make_json_file
  set_all_files
  redirect to('/memos')
end

get '/memos/new' do # 新規登録
  erb :form
end

get '/memos/:id' do # 詳細画面
  set_all_files
  erb :show
end

delete '/memos/:id' do # 削除機能
  File.delete(set_file)
  redirect to('/memos')
end

get '/memos/:id/edit' do # 編集画面
  edit_memo = File.open(set_file, 'r+').read
  @edit_memo = JSON.parse(edit_memo)
  erb :edit_memo
end

patch '/memos/:id' do # 編集機能
  file = File.open(set_file).read
  update_file = JSON.parse(file)
  update_file['title'] = params['title']
  update_file['content'] = params['content']
  File.open("public/notes/#{update_file['id']}_note.json", 'w') { |f| JSON.dump(update_file, f) }
  redirect to('/memos')
end
