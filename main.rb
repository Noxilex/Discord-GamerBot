require 'discordrb'
bot = Discordrb::Commands::CommandBot.new token: 'MjYzMjQ2NDkzNTM4ODQ0Njgz.C0PPyQ.udDki5kMbF5B0QSdVLOOCfi61Vc', client_id: 263246493538844683, prefix: '!'

bot.command :owstats do |event, user, option, platform="pc", region="eu"|
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

bot.command :random do |event, min, max|
  rand(min.to_i .. max.to_i)
end

bot.run
