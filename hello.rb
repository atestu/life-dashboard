require 'rubygems'
require 'sinatra'
require 'hpricot'
require 'rest-open-uri'
require 'rest-client'
require 'json'
require 'net/http'
require 'xmlsimple'
require 'date'

$accessToken = ''

get '/oauth2callback' do
  response = RestClient.post 'https://accounts.google.com/o/oauth2/token',
      :code => params[:code],
      :client_id => ENV['GLDCLIENTID'],
      :client_secret => ENV['GLDCLIENTSECRET'],
      :redirect_uri => ENV['GLDREDIRECTURL'],
      :grant_type => "authorization_code"
  result = JSON.parse(response)
  result.each do |key, value|
    puts "#{key} => #{value}"
  end
  $accessToken = result['access_token']
  redirect '/'
end

get '/' do
  begin
    @calendar = open("https://www.google.com/calendar/feeds/default/private/full?orderby=starttime&max-results=15&singleevents=true&sortorder=ascending&futureevents=true&access_token=#{$accessToken}") { |f| Hpricot.XML(f) }
  rescue
    redirect "https://accounts.google.com/o/oauth2/auth?client_id=#{ENV['GLDCLIENTID']}&redirect_uri=#{ENV['GLDREDIRECTURL']}&scope=https://www.google.com/calendar/feeds/&response_type=code"\
  end
  amazon = open('http://rssfeeds.s3.amazonaws.com/goldbox') { |f| Hpricot(f) }
  (amazon/"item").each do |item|
    if (item.at("title").inner_html.include? "Deal of the Day") then
      @dealoftheday = Hpricot("<a href='#{item.at('link').inner_html}'>#{item.at('title').inner_html}</a>")
      break
    end
  end
  
  @todayArray = []
  @tomorrowArray = []
  @laterArray = []
  @events = (@calendar/'feed')
	(@events/'entry').each do |entry|
	  if (Date::parse("#{(entry/"gd:when")[0]['startTime']}").eql?(Date::today)) then
	    @todayArray << {'title' => (entry/'title').inner_html, 'date' => DateTime::_parse("#{(entry/"gd:when")[0]['startTime']}")}
	  else
	    if (Date::parse("#{(entry/"gd:when")[0]['startTime']}").eql?(Date::today.next)) then
        @tomorrowArray << {'title' => (entry/'title').inner_html, 'date' => DateTime::_parse("#{(entry/"gd:when")[0]['startTime']}")}
      else
        if (Date::parse("#{(entry/"gd:when")[0]['startTime']}").eql?(Date::today.next.next) ||
          Date::parse("#{(entry/"gd:when")[0]['startTime']}").eql?(Date::today.next.next.next) ||
          Date::parse("#{(entry/"gd:when")[0]['startTime']}").eql?(Date::today.next.next.next.next)) then
          @laterArray << {'title' => (entry/'title').inner_html, 'date' => DateTime::_parse("#{(entry/"gd:when")[0]['startTime']}")}
        end
      end
    end
	end
  puts @events
  erb :index
end