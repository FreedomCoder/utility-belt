# automate creating twitts
%w{net/http json platform utility_belt}.each {|lib| require lib}
UtilityBelt.equip(:clipboard)

module UtilityBelt
  module Twitty
    def twitt(message = nill)
      message ||= Clipboard.read if Clipboard.available?
      if message.length > 160
        Raise ArgumentError, "Message should be shorter than 160 characters"
      else
        http = Net::HTTP.new("twitter.com",80)
        http.start do |http|
          request = Net::HTTP::Post.new("/statuses/update.json")
          request.basic_auth(ENV['TWITTER_USER'], ENV['TWITTER_PWD'])
          response = http.request(request, "status=#{URI.escape(message)}")
          case response
            when Net::HTTPSuccess, Net::HTTPRedirection
                return "Success!"
            else
                return response.error!
          end
        end
        http.close
      end
    end

    def fetch_twitt
      http = Net::HTTP.new("twitter.com",80)
      http.start do |http|
        request = Net::HTTP::Get.new("/statuses/friends_timeline.json")
        request.basic_auth(ENV['TWITTER_USER'], ENV['TWITTER_PWD'])
        response = http.request(request)
        case response
          when Net::HTTPSuccess, Net::HTTPRedirection
            JSON.parse(response.body).each do |twitt|
              screen_name = twitt["user"]["screen_name"]
              text = twitt["text"]
              case Platform::IMPL
                when :macosx || :linux
                  puts "\033[31m#{screen_name}\033\[0m => \033[33m#{text}\033\[0m"
                when :mswin
                   puts "#{screen_name} => #{value}"
              end
            end
            return "true"
         else
           return response.error!
        end
      end
    end
  end
end

class Object
  include UtilityBelt::Twitty
end if Object.const_defined? :IRB