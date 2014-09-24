require "sinatra"
require "octokit"

set :views, Proc.new {File.join(root, '..', "views")}
set :public_folder, Proc.new {File.join(root, '..', "public")}

enable :sessions

set :session_secret, ENV['GITHUB_SECRET']

set :logging, false

get "/" do 
	erb :index
end

post '/username' do
	@client ||= Octokit::Client.new(access_token: ENV['GITHUB_TOKEN'])
	@username = params[:mode]
	begin @user = @client.user @username rescue @user = nil end
	@public_repos = @user.rels[:repos].get.data
	if @public_repos != []	
		@all_languages = @public_repos.map { |repo| repo[:language] }.compact.inject(Hash.new(0)) { |lang, freq| lang[freq] += 1 ; lang }
		if @all_languages.values != []
			@languages = @all_languages.group_by{ |lang, freq| freq }.max.last.map {|lang| lang[0]}
			if @languages.count == 1
				@languages_list = "Most common language: " + @languages.join(', ')
			else
				@languages_list = "Most common languages: " + @languages.join(', ')
			end
		else
			@languages_list = "Most common language: Not available"
		end
	else
		@languages_list = "Most common language: Not available"
	end
	@languages_list
end

