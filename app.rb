require "sinatra"
require "uri"
require "httparty"

get '/auth' do
  query = {
    client_id: ENV["GITHUB_APP_ID"],
    redirect_uri: "#{env['rack.url_scheme']}://#{env['HTTP_HOST']}/auth.callback",
    scope: "repo"
  }.map{|k,v|
    "#{k}=#{URI.encode v}"
  }.join("&")
  redirect "https://github.com/login/oauth/authorize?#{query}"
end

get '/auth.callback' do
  code = params["code"]
  halt 400, "bad request (code)" if code.to_s.empty?

  ## get oauth token
  query = {
    :body => {
      :client_id => ENV["GITHUB_APP_ID"],
      :client_secret => ENV["GITHUB_APP_SECRET"],
      :code => code
    },
    :headers => {
      "Accept" => "application/json"
    }
  }
  res = HTTParty.post("https://github.com/login/oauth/access_token", query)
  halt 500, "github auth error" unless res.code == 200
  begin
    token = JSON.parse(res.body)["access_token"]  ## tokenを取得！
  rescue
    halt 500, "github auth error"
  end
  ## sessionに保存するなど自由に
  redirect '/'
end
