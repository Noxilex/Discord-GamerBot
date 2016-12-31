require 'discordrb'
require 'configatron'
require_relative 'config.rb'

bot = Discordrb::Commands::CommandBot.new token: configatron.token, client_id: 263246493538844683, prefix: '!'

bot.command(:owstats, channels: ["#bot_testing", "#spam", "#general"])  do |event, user, option, platform="pc", region="eu"|
	uri = URI('http://ow-api.herokuapp.com/stats/'+platform+'/'+region+'/'+user.sub('#','-'))
	res = Net::HTTP.get_response(uri)
	obj = JSON.parse(res.body)
	result = "#{event.user.mention}\n"
	result += "```Player: #{user}\n"
	if(option == "played")
		result += "Quickplay: #{obj["stats"]["game"]["quickplay"][3]["value"]}\nCompetitive: #{obj["stats"]["game"]["competitive"][4]["value"]}"
	elsif (option == "winrate")
		games_played = obj["stats"]["game"]["competitive"][0]["value"].to_f
		games_won = obj["stats"]["game"]["competitive"][1]["value"].to_f
		ratio = games_won/games_played
		percent = ratio*100;
		percent_format = "%5.2f" % percent
		result += "Competitive: #{percent_format}% winrate"
	end
	result += "```"
end

bot.command(:loltest) do |event, user, option, region="euw"|
	api_key = configatron.lolAPI
	
	#Puts champions id in an array
	champs = JSON.parse(Net::HTTP.get_response(URI('https://global.api.pvp.net/api/lol/static-data/'+region+'/v1.2/champion?api_key='+api_key)).body)
	format_champs[]
	champs['data'].each do |champ|
		format_champs << [champ['id'], champ['name']]
	end
	puts format_champs
end

bot.command(:lolstats, channels: ["#bot_testing", "#spam", "#general"]) do |event, user, option, region="euw"|
	api_key = configatron.lolAPI

	

	uri = URI('https://euw.api.pvp.net/api/lol/'+region+'/v1.4/summoner/by-name/'+user+'?api_key='+api_key)
	res = Net::HTTP.get_response(uri)
	obj = JSON.parse(res.body)
	puts obj.to_s
	player_id = obj[user.downcase]['id']
	puts player_id
	season = '6'
	uri2 = URI('https://euw.api.pvp.net/api/lol/euw/v1.3/stats/by-summoner/'+player_id.to_s+'/ranked?season=SEASON2016&api_key='+api_key)
	res2 = Net::HTTP.get_response(uri2)
	obj2 = JSON.parse(res2.body)
	result = "#{event.user.mention}\n"
	result += "```Player: #{user}\n"
	#Most played champions

	
	obj2['champions'].each do |champion| 
		uri_champ = URI('https://global.api.pvp.net/api/lol/static-data/euw/v1.2/champion/'+champion['id'].to_s+'?api_key='+api_key)
		res_champ = Net::HTTP.get_response(uri_champ)
		obj_champ = JSON.parse(res_champ.body)
		stats = champion['stats']
		kills = stats['totalChampionKills'].to_f
		assists = stats['totalAssists'].to_f
		deaths = stats['totalDeathsPerSession'].to_f
		kda = ((kills+assists)/deaths)
		kda_format = "%5.2f" % kda
		result += "Champion: #{obj_champ['name']}\n";
		result += "\tKDA: #{kda_format}\n"
	end
	
	result += "```"
end

bot.command :random do |event, min, max|
  rand(min.to_i .. max.to_i)
end

bot.run
