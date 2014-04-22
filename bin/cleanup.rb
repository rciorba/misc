#!/usr/bin/env ruby

require "rubygems"
require "optparse"
require "date"


options = {}
optparse = OptionParser.new do|opts|
  opts.banner = "Usage: prune-branches.rb PATH_TO_REPO [OPTIONS]"
  options[:age] = 14
  opts.on('-a', '--age DAYS', 'Age in days of last commit on branch. Defaults to 14.' ) do|age|
    options[:age] = Integer(age)
  end
  options[:dry] = false
  opts.on('--dry', 'Dry run. Just print what branches are going to be deleted.' ) do |dry|
    options[:dry] = dry
  end
  options[:local] = false
  opts.on('--local', 'Remove local branches.' ) do |local|
    options[:local] = local
  end
  options[:skip] = ["master"]
  opts.on('--skip b1,b2', Array, 'Comma separated list of branches to skip.' ) do |skip|
    options[:skip] += skip
  end
end
optparse.parse!


if options[:local]
  branches = `git branch`.split("\n")
else
  branches = `git branch --remotes`.split("\n")
end
now = DateTime.now


for branch in branches
  branch.strip!
  if branch.start_with?("* ")
    branch = branch[2..-1]
  end
  skip = false
  for exclude in ["origin/HEAD", "origin/master"]
    if branch.start_with?(exclude)
      skip = true
    end
  end
  if not branch.start_with?("origin/PBSLM-")
    puts "does not match name: #{branch}"
    skip = true
  end
  if skip
    next
  end
  # puts "="+branch+"="
  # puts "git show #{branch}"
  data = `git show #{branch}`.split("\n")
  date_line = data.select{|d| d.start_with?("Date:")}[0]
  date = DateTime.parse(date_line)
  age = now-date
  if age > options[:age]
    puts "deleteing #{branch}"
    if not options[:dry]
      if options[:local]
        `git branch -D #{branch}`
      else
        name = branch.sub(/origin\//, '')
        puts "git push origin :#{name}"
        `git push origin :#{name}`
      end
    end
  end
end
