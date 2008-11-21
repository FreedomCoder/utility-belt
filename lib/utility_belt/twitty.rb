# automate creating twitts
%w{net/http utility_belt}.each {|lib| require lib}
UtilityBelt.equip(:clipboard)

module UtilityBelt
  module Twitty
    def twitt(message = nill)
      message ||= Clipboard.read if Clipboard.available?
      if message.length > 160
        Raise ArgumentError "Message should be shorter than 160 characters"
      else
        http = Net::HTTP.new("twitter.com",80)
        http.start do |http|
          request = Net::HTTP::Post.new("/statuses/update.json")
          request.basic_auth(ENV['TWITTER_USER'], ENV['TWITTER_PWD'])
          response = http.request(request, "status=#{URI.escape(message)}")
          case response
            when Net::HTTPSuccess, Net::HTTPRedirection
                return "Success! message: #{message} uploaded"
            else
                return response.error!
          end
        end
      end
    end
  end
end
