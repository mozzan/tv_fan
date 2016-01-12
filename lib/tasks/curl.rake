class Channel
  attr_accessor :id, :name, :day, :list

  def initialize(id, name, day)
    @id = id
    @name = name
    @day = day
    @list = Array.new
  end
end

class Program
  attr_accessor :name, :time

  def initialize(name, time)
    @name = name
    @time = time
  end
end

class Parser
  require "net/https"
  attr_accessor :domain, :url, :day, :groupId
# 
  def initialize(domain, url, day, groupId)
    @domain = domain
    @url = url
    @day = day
    @groupId = groupId
  end

  def doGetHtml
    http = Net::HTTP.new @domain, 80
    puts @url + "&tday=#{@day}&group_id=#{@groupId}"
    request = Net::HTTP::Get.new @url + "&tday=#{@day}&group_id=#{@groupId}"
    content = http.request(request).body
    File.open("xx", 'w:ASCII-8BIT') { |file| file.write(content) }
    return content
  end

  def doParse
    response = doGetHtml
    result = Hash.new
    unless(response.nil?)
      tv = response.scan(/<a class=at15b.+channel_id=([A-Z0-9]+)&.+>(.+)<\/a>/i)
      tv.each do |id, name|
        channel = Channel.new(id, name, @day)
        result[id] = channel
      end
      
      list = response.scan(
          /<td align=\"center\" class=at9>(.+)<\/td>\s+.+\s*.*\s+.+&channel_id=([A-Z0-9]+)\">\s+<font class=at11>(.+)<\/font><\/a><font color=#[0-9a-fA-F]+>(.+)<\/font><\/font>/i)
      list.each do |time, id, name1, name2|
        program = Program.new(name1.strip + ' ' + name2.strip, time.strip)
        result[id].list << program
      end
    end
    return result
  end
end

namespace :curl do
  desc "TODO"
  task movie: :environment do
    parser = Parser.new("tv.atmovies.com.tw", "/tv/attv.cfm?action=todaytime", "2016-01-12", "M")
    parser.doParse
  end
end