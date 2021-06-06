#!/usr/bin/env ruby

# ./generate-master.rb ~/tmp/win98/00-tjh/iracing-cars-20210530/Cars.html-owned.html

require "json"
require "uri"

def main(filename)
  lines = File.readlines(filename).map { |s| s.force_encoding(Encoding::ASCII_8BIT) }.grep(/^var OwnedContentListing =/)
  raise "OwnedContentListing" unless lines.size == 1
  json = lines[0].sub(%r(^var OwnedContentListing = extractJSON\('), "").sub(%r('\);$), "")
  ownedContent = JSON.parse(json)

  lines = File.readlines(filename).map { |s| s.force_encoding(Encoding::ASCII_8BIT) }.grep(/^var UnownedAllowedContentListing =/)
  raise "UnownedAllowedContentListing" unless lines.size == 1
  json = lines[0].sub(%r(^var UnownedAllowedContentListing = extractJSON\('), "").sub(%r('\);$), "")
  unownedAllowedContent = JSON.parse(json)

  content = (ownedContent + unownedAllowedContent).map { |o| [o["pkgid"], o] }.to_h

  lines = File.readlines(filename).map { |s| s.force_encoding(Encoding::ASCII_8BIT) }.grep(/^var CategoryListing =/)
  raise "CarListing" unless lines.size == 1
  json = lines[0].sub(%r(^var CategoryListing = ), "").sub(%r(;$), "")
  categories = JSON.parse(json).values

  lines = File.readlines(filename).map { |s| s.force_encoding(Encoding::ASCII_8BIT) }.grep(/^var CarListing =/)
  raise "CarListing" unless lines.size == 1
  json = lines[0].sub(%r(^var CarListing = extractJSON\('), "").sub(%r('\);$), "")
  cars = JSON.parse(json)

  lines = File.readlines(filename).map { |s| s.force_encoding(Encoding::ASCII_8BIT) }.grep(/^var TrackListing =/)
  raise "TrackListing" unless lines.size == 1
  json = lines[0].sub(%r(^var TrackListing = extractJSON\('), "").sub(%r('\);$), "")
  tracks = JSON.parse(json)

  # puts content
  # puts categories
  # puts cars
  # puts tracks

  if true
    cars_decoded = cars.map do |o|
      id = o["id"]
      shortName = URI.decode_www_form_component(o["dirpath"]).tr('\\', ' ')
      longName = URI.decode_www_form_component(o["name"])
      { id: id, shortName: shortName, longName: longName }
    end
    l = cars_decoded.sort_by { |o| o[:longName] }.map do |o|
      "{ id = #{o[:id]}, shortName = \"#{o[:shortName]}\", longName = \"#{o[:longName]}\" }"
    end
    puts
    puts
    puts "cars : Dict Car.Id Car.Car"
    puts "cars ="
    puts "    toDict"
    print "        [ "
    print l.join("\n        , ")
    puts "\n        ]"
  end

  if true
    l = ["{ id = -1, shortName = \"baseline\", longName = \"<baseline>\" }"]
    tracks_decoded = tracks.map do |o|
      pkgid = o["pkgid"]
      id = o["id"]
      shortName, comment =
        if !content[pkgid]
          $stderr.puts "can't find content of pkgid '#{pkgid}' of track '#{o}'"
          [ URI.decode_www_form_component(o["lowerNameAndConfig"]).chomp(" "),
            "can't find package of pkgid '#{pkgid}'" ]
        else
          [ [content[pkgid]["JSVar"].sub(/^tracks_/, ""), URI.decode_www_form_component(o["config"]).downcase].filter { |s| !s.empty? }.join(" "),
            nil ]
        end
      longName = [URI.decode_www_form_component(o["name"]), URI.decode_www_form_component(o["config"])].filter { |s| !s.empty? }.join(" - ")
      fixes = { 385 => "charlotte 2018 2019 rallycrosslong" }
      shortName = fixes[id] || shortName
      { id: id, shortName: shortName, longName: longName, comment: comment }
    end
    l += tracks_decoded.sort_by { |o| o[:longName] }.map do |o|
      ["{ id = #{o[:id]}, shortName = \"#{o[:shortName]}\", longName = \"#{o[:longName]}\" }", o[:comment]].compact.join(" -- ")
    end

    puts
    puts
    puts "tracks : Dict Track.Id Track.Track"
    puts "tracks ="
    puts "    toDict"
    print "        [ "
    print l.join("\n        , ")
    puts "\n        ]"
  end

end

raise "usage: #{$0} Cars.html" unless ARGV.size == 1

main(ARGV[0])
