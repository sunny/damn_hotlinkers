#!/usr/bin/ruby
# Die, damn hotlinkers!
# by Sunny Ripert - sunfox.org
# Use it against an HTTP log to find out who points directly towards your files

require 'set'

class DamnHotlinkers
  MATCH_URI = /\.(jpg|jpeg|png|gif|mp3|ogg|mov|flv|mpeg|swf|avi)$/

  attr_reader :leeches

  def initialize
    @leeches = Hash.new { |h,k| h[k] = Set.new } # handy hash defaults to empty Set
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
      next if ref == "-" or ref =~ /:\/\/#{domain}/

      @leeches[uri].add ref
    end
    self
  end

  # Pretty representation of sorted leeches
  def to_s
    leeches.sort.collect do |uri, referrers|
      [uri] + referrers.sort.collect { |ref| "  -> #{ref}" }
    end.join("\n")
  end
end

if __FILE__ == $0
  abort "Usage: #{$0} file.log [file2.log ...]" if ARGV.empty?
  damn_them = DamnHotlinkers.new
  ARGV.each { |arg| damn_them.load(arg) }
  puts damn_them
end
