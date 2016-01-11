class TV
  attr_accessor :name, :time

  def initialize(name, time)
    @name = name
    @time = time
  end
end

class Parser
  require "net/https"
  attr_accessor :domain, :prefix, :extraUrl

  def initialize(domain, prefix, extraUrl)
    @domain = domain
    @prefix = prefix
    @extraUrl = extraUrl
  end

  def doGetHtml
    http = Net::HTTP.new @domain, 80
    request = Net::HTTP::Get.new @prefix
    http.request request
  end

  def doParse
    response = doGetHtml
    unless(response.nil?)
      res = []
      response.body.scan(/<a class=at15b.+channel_id=CH[0-9]+&.+>(.+)<\/a>/i) do |index|
        res << [index, $~.offset(0)[0]]
      end

      start = 0
      prePack = nil
      res.each do |pack, index|
        pack.each do |name|
          #tv = TV.new
          #tv.name = name
          puts name
        end
        # list is previous tv's result

        list = []
        timeList = response.body[start, index]
                .scan(/<td align="center" class=at9>(.+)<\/td>/i)

        tvlist = response.body[start, index]
                .scan(/<font class=at11>(.+)<\/font><\/a><font color=#[0-9a-fA-F]+>(.+)<\/font><\/font>/i)

        index = 0
        tvlist.each do |name|
          tv = TV.new(name[0].strip + ' ' + name[1].strip, timeList[index])
          list << tv
          index += 1
        end
        puts list.size
        # puts list.inspect
        start = index
        prePack = pack
      end
    end
  end

end

namespace :curl do
  desc "TODO"
  task movie: :environment do
    parser = Parser.new("tv.atmovies.com.tw", "/tv/attv.cfm?action=todaytime", nil)
    parser.doParse
  end
end