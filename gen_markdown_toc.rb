#!/usr/bin/env ruby

TOP = 2 ; MAX = 4

def usage
  puts <<~EOF
    Usage: #{$0} FILE.md [TOP [MAX]] [-h]
    FILE.md is your Markdown source document.
    TOP is the top-level Markdown heading level in your document. Default is #{TOP}.
    MAX is the maximum heading level to include in your table of contents. Default is #{MAX}.
  EOF
  exit 1
end

class ToCWriter
  def initialize(source_file, top=TOP, max=MAX)
    @source_file = source_file
    @top = top.to_i
    @max = max.to_i
    @count = 1
    @level  = ""
    @header = ""
    @start  = ""
  end

  def write
    puts "#### Table of contents\n\n"

    File.open(@source_file).each_line do |line|
      next unless line.match(/^#/)

      @level, @header = line.match(/^(#+) *(.*)/).captures
      next if ignore_this_header?

      ref = header_to_ref
      set_start

      puts "#{@start} [#{@header}](##{ref})"
    end
  end

 private

  def ignore_this_header?
    @header == "Table of contents" || \
      @level.length < @top || \
      @level.length > @max
  end

  def header_to_ref
    @header
      .downcase
      .gsub(/[^a-z\d_\- ]+/, "")
      .gsub(/ /, "-")
      .gsub(/-$/, "")
  end

  def set_start
    len = @level.length
    if len == @top
      @start = "#{@count}."
      @count += 1
    else
      bullet = len % 2 == 0 ? "-" : "*"
      @start = "    " * (len - @top) + bullet
    end
  end
end

usage unless ARGV.length > 0
usage if ARGV[0] == "-h"

ToCWriter.new(*ARGV).write
