#!/usr/bin/ruby
# Die, damn hotlinkers!
# by Sunny Ripert - sunfox.org
# Use it against an HTTP log to find out who points directly towards your files

require 'set'
require 'date'

class DamnHotlinkers
  MATCH_URI = /\.(jpg|jpeg|png|gif|mp3|ogg|mov|flv|mpeg|swf|avi)$/
  IGNORE_REF = Regexp.compile %w(
    http://www.google.com/reader
    http://images.search.yahoo.com
    /search?q=cache:
  ).map { |uri| Regexp.escape uri }.join('|')

  attr_reader :leeches

  def initialize(days_ago = nil)
    @leeches = Hash.new { |h,k| h[k] = Set.new } # handy hash defaults to empty Set
    @min_date = days_ago.nil? ? nil : Date.today - days_ago
  end

  # Add leeches from an Apache-like HTTP logfile
  # filename accepts whatever resource open() accepts
  def load(filename)
    open(filename).each do |line|
      split = line.split

      domain = split[1]
      uri = split[6]
      uri = "http://#{domain}#{uri}"
      next unless uri =~ MATCH_URI

      ref = split[10]
      ref = ref[1..ref.length-2] rescue next # unquote the referrer
      next if ref == "-" or ref =~ /:\/\/#{domain}/ or ref =~ IGNORE_REF

      next if !@min_date.nil? and Date.parse(split[3]) < @min_date

      @leeches[uri].add ref
    end
    self
  end

  # Pretty representation of sorted leeches
  def to_s(rep = nil)
    return to_html if rep == :html
    leeches.sort.collect do |uri, referrers|
      [uri] + referrers.sort.collect { |ref| "  -> #{ref}" }
    end.join("\n")
  end

  # Same thing with a little more markup
  def to_html
    lis = leeches.sort.collect do |uri, referrers|
      refs = referrers.sort.collect { |ref| "<li><a href='#{ref}'>#{ref}</a></li>\n" }
      "<li><a href='#{uri}'>#{uri}</a><ul>#{refs}</ul></li>\n"
    end
    "<ul>#{lis}</ul>"
  end
end

if __FILE__ == $0
  days_ago = nil
  if ARGV.first =~ /^--days=(\d+)$/
    days_ago = $1.to_i
    ARGV.shift
  end

  representation = nil
  if ARGV.first == "--html"
    representation = :html
    ARGV.shift
  end

  abort "Usage: #{$0} [--days=N] [--html] file.log [file2.log ...]" if ARGV.empty?

  damn_them = DamnHotlinkers.new(days_ago)
  ARGV.each { |arg| damn_them.load(arg) }
  puts damn_them.to_s(representation)
end
