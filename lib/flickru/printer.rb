# gems
require 'colorize'
# flickru
require 'flickru/ruby'

module Printer

  def self.human_readable_seconds seconds
    Ruby.assert("seconds >= 0") { seconds >= 0 }

    return "%.1f" % seconds + " seconds" if seconds < 60
    minutes  = seconds / 60
    return "%.1f" % minutes + " minutes" if minutes < 60
    hours    = minutes / 60
    return "%.1f" % hours   + " hours"   if hours   < 24
    days     = hours / 24
    return "%.1f" % days    + " days"
  end

  def self.show msg
    print msg
  end

  def self.info msg
    puts msg.cyan
  end

  def self.warn msg
    puts ("warning: " + msg).magenta
  end

  def self.error msg
    STDERR.puts msg.red
  end

  def self.enter msg
    print (">>> " + msg + ": ").black
  end

  def self.ask msg
    puts ("*** " + msg + " ***").light_blue
  end

  def self.success
    puts "done".green
  end

  def self.failure msg=nil
    puts ("fail" + (msg.nil? ? "" : ": " + msg)).red
  end

end
