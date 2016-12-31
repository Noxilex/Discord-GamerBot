require 'discordrb'
require 'configatron'
require_relative 'config.rb'

bot = Discordrb::Commands::CommandBot.new token: 'configatron.token', client_id: 263246493538844683, prefix: '!'

bot.command(:owstats, channels: ["#bot_testing", "#spam", "#general"])  do |event, option, user, platform="pc", region="eu"|
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

bot.command :lolstats do |event, option, user, region="eu"|
	api_key = "RGAPI-1048F028-BC6A-46DD-A599-4616B04AD861"
	url = "https://euw.api.pvp.net/api/lol/"+region+"/v1.4/summoner/by-name/"+user+"?api_key="+api_key
	uri = URI('http://ow-api.herokuapp.com/stats/'+platform+'/'+region+'/'+user.sub('#','-'))
	res = Net::HTTP.get_response(uri)
	obj = JSON.parse(res.body)
	result = "#{event.user.mention}\n"
	result += "```Player: #{user}\n"

	result += "```"
end

bot.command :random do |event, min, max|
  rand(min.to_i .. max.to_i)
end

bot.run
