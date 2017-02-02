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
		#games_played = obj["stats"]["game"]["competitive"][0]["value"].to_f
		miscellanous = obj["stats"]["miscellaneous"]["competitive"]
		games_lost = 0
		miscellanous.each {|x|
			title= x["title"]
			value= x["value"]
			if(title == "Games Lost")
				games_lost = value.to_f;
			end
		}
		games_won = obj["stats"]["game"]["competitive"][1]["value"].to_f
		#puts "Lost: #{games_lost}"
		#puts "Won: #{games_won}"
		ratio = games_won/(games_won+games_lost)
		percent = ratio*100;
		percent_format = "%5.2f" % percent
		result += "Competitive: #{percent_format}% winrate\n"
		result += "Games won: #{games_won.to_i}\n"
		result += "Games lost: #{games_lost.to_i}"
	end
	result += "```"
end

bot.command(:loltest) do |event, user, option, region="euw"|
	api_key = configatron.lolAPI
	
	#Puts champions id in an array
	champs = JSON.parse(Net::HTTP.get_response(URI('https://global.api.pvp.net/api/lol/static-data/'+region+'/v1.2/champion?api_key='+api_key)).body)
	format_champs = Hash.new
	champs['data'].each do |champ|
		champ_data = champ[1]
		champ_id = champ_data['id']
		champ_name = champ_data['name']
		format_champs[champ_id] = champ_name
	end
end

bot.command(:lolstats, channels: ["#bot_testing", "#spam", "#general"]) do |event, user, option, region="euw"|
	api_key = configatron.lolAPI

	#List all champion ids with associated name in hash (format_champs[id] = name)
	champs = JSON.parse(Net::HTTP.get_response(URI('https://global.api.pvp.net/api/lol/static-data/'+region+'/v1.2/champion?api_key='+api_key)).body)
	format_champs = Hash.new
	champs['data'].each do |champ|
		champ_data = champ[1]
		champ_id = champ_data['id']
		champ_name = champ_data['name']
		format_champs[champ_id] = champ_name
	end
	
	#Gets player ID
	encoded_user = URI.encode_www_form_component(user)
	uri = URI('https://euw.api.pvp.net/api/lol/'+region+'/v1.4/summoner/by-name/'+encoded_user+'?api_key='+api_key)
	res = Net::HTTP.get_response(uri)
	obj = JSON.parse(res.body)
	player_id = obj[user.downcase]['id']
	
	#Gets top 3 best champions
	top3 = JSON.parse(Net::HTTP.get_response(URI('https://euw.api.pvp.net/championmastery/location/EUW1/player/'+player_id.to_s+'/topchampions?api_key='+api_key)).body)
	top3_a = Hash.new
	top3.each do |champion|
		id = champion['championId'] 
		points = champion['championPoints']
		level = champion['championLevel']
		last_played = champion['lastPlayTime']
		top3_a[id] = {"name" => format_champs[id], "level" => level, "points" => points, "last_played" => last_played}
	end
	puts top3_a.to_s

	#Gets stats from associated season + player
	season = '6'
	uri2 = URI('https://euw.api.pvp.net/api/lol/euw/v1.3/stats/by-summoner/'+player_id.to_s+'/ranked?season=SEASON201'+season+'&api_key='+api_key)
	res2 = Net::HTTP.get_response(uri2)
	s = JSON.parse(res2.body)

	result = "#{event.user.mention}\n"
	result += "```Player: #{user}\n"

	#Champions stats for respective season
	s['champions'].each do |champion|
		id = champion['id']
		if top3_a.has_key?(id)
			current = top3_a[id]
			stats = champion['stats']
			kills = stats['totalChampionKills'].to_f
			assists = stats['totalAssists'].to_f
			deaths = stats['totalDeathsPerSession'].to_f
			kda = ((kills+assists)/deaths)
			kda_format = "%5.2f" % kda
			result += "Champion: #{current['name']}\n";
			result += "\tLevel: #{current['level']}\n";
			result += "\tPoints: #{current['points']}\n";
			result += "\tKDA: #{kda_format}\n";
		end
	end
	
	result+= "```"
end

bot.command :random do |event, min, max|
  rand(min.to_i .. max.to_i)
end

bot.run
