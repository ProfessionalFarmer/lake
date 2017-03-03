#!/usr/bin/env ruby

require 'optparse'

# Author: Zhongxu Zhu. Ruby is wonderful!
# Create on: 20160914, Modified on: 20160919

options = {}
option_parser = OptionParser.new do |opts|
  # help description 
  opts.banner = 'Add a string in a specific column (left or right). Or remove a string in a specific column'
  
  # option type: switch
  options[:rigth] = false
  # Short option, Long option, Option description
  opts.on('-r', '--right', 'Add postion: -r (--rigth) or left (default)') do
    options[:right] = true
  end
  options[:remove] = false
  opts.on('', '--remove', 'Remove a string in specific column (default false)') do
    options[:remove] = true
  end


  options[:header] = true
  # Short option, Long option, Option description
  opts.on('', '--noheader', 'whether header exists (default: true)') do
    options[:header] = false
  end

  #option type: flag
  options[:target] = 1
  opts.on('-c ', '--col int', Integer, 'Target column (default 1)') do |value|
    options[:target] = value
  end

  options[:string] = ''
  opts.on('-s ', '--string str', String, 'The string you want to add (default null)') do |value|
    options[:string] = value
  end

  options[:input] = nil
  opts.on('-i ', '--input file', String, 'Input file path (if not, use stdin)') do |value|
    options[:input] = value
  end

end.parse!



if options[:input]!=nil then
    file=File.open(options[:input],"r")
else
    file=STDIN
end

# count line number except header
i=-1
while line = file.gets
#  skip comment line
   if line[0] == '#' then
        next
   end
   if i==-1 and options[:header]==true then
        puts line
        i=0
        next
   end
   if i==-1 then
        i=0
   end
   i=i+1
begin
   list=line.split("\t")
   if options[:remove] then
       list[options[:target]-1] = list[options[:target]-1].gsub(options[:string],'')
   else
       if options[:right] then
           list[options[:target]-1] = list[options[:target]-1] + options[:string]
       else
           list[options[:target]-1] = options[:string] + list[options[:target]-1]
       end
   end
   puts list.join("\t")
rescue ArgumentError
   STDERR.puts 'rescue a line in LineNum (not include header): ' + i.to_s
   next
end

end








