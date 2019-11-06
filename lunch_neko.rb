require 'slack-ruby-bot'
require 'rest-client'
require 'json'

class LunchNeko < SlackRubyBot::Bot

  command 'menus' do |client, data, match|
    client.say(text: transform_menus_to_slack_message(fetch_menus), channel: data.channel)
  end

  def self.fetch_menus
    api_response = RestClient.get(ENV.fetch('LUNCH_MENU_API'))
    JSON.parse(api_response.body, symbolize_names: true)
  end

  def self.skip_restaurant?(restaurant)
    ENV.fetch('RESTAURANT_SKIP_LIST', []).split(',').include? restaurant
  end

  def self.transform_menu_to_slack_message(menu)
    StringIO.open do |s|
      s << "*#{menu[:name]}*\n"
      menu[:specials].each do |dish|
        s << "- #{dish}\n"
      end
      s.string
    end
  end

  def self.transform_menus_to_slack_message(menus)
    StringIO.open do |s|
      s << "\n *MENUS* \n"
      menus.each do |menu|
        next if skip_restaurant? menu[:name]
        s << transform_menu_to_slack_message(menu)
        s << "\n"
      end
      s.string
    end
  end
end

LunchNeko.run