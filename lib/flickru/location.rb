# ruby
require 'rbconfig'
# gems
require 'colorize'
require 'escape'
# flickru
require 'flickru/ruby'
require 'flickru/string'

class Location

  GEOWIKI = File.expand_path(File.join File.dirname(__FILE__), '..', '..', 'bin', 'geowiki')
  DEFAULT_ACCURACY = "street"
  COORD_PATTERN = "-?[0-9]+\.?[0-9]*"

  attr_accessor :name, :place, :latitude, :longitude, :accuracy

  def initialize photo
    dir   = File.basename File.dirname(photo)
    name, place, accuracy = Location.parse dir
    raise RuntimeError, "unnamed location #{dir}" if name.nil?
    @name = name
    begin
      @place    = place.nil? ? name : place
      @latitude, @longitude = Location.locate @place
      @accuracy = Location.s_to_accuracy(accuracy ? accuracy : DEFAULT_ACCURACY)
    rescue RuntimeError
      raise if place
      raise RuntimeError, "location #{name} not found" if accuracy
      @place, @latitude, @longitude, @accuracy = nil # no location
    end
  end

  def nil?
    Ruby.assert("@accuracy.nil? implies @latitude.nil? and @longitude.nil?") {
      @accuracy.nil? or not (@latitude.nil? and @longitude.nil?)
    }

    @accuracy.nil?
  end

  def to_s
    place = @place.nil? ? "an undefined place" : @place
    "#{@name.black} at #{place.black} (~#{accuracy_to_s.black}) " +
    "on lat: #{@latitude.black}, lon: #{@longitude.black}"
  end

private

  def self.parse location
# TODO special characters MAY be escaped
    idx_accuracy = location.index('#') ? location.index('#') : location.length
    idx_place    = location.index('@') ? location.index('@') : idx_accuracy

    name     = location.sub(/[@#].*$/, '').strip | nil
    place    = location.index('@') ? location.sub(/^.*@/, '').sub(/\#.*$/, '').strip : nil
    accuracy = location.index('#') ? location.sub(/^.*#/, '').strip : nil

    [name, place, accuracy]
  end

  def self.locate place
    the_place = place # needed for RuntimeError reporting
    begin
      is_win  = case RbConfig::CONFIG['target_os']
                when /mswin|mingw|cygwin/i then true
                else false end
      command = Escape.shell_command((is_win ? ['bash'] : []) + [GEOWIKI, place])
      null    = is_win ? 'NUL' : '/dev/null'
      place = `#{command} 2> #{null}`[0..-2] \
        if place !~ /^#{COORD_PATTERN}, *#{COORD_PATTERN}$/
      if place =~ /^#{COORD_PATTERN}, *#{COORD_PATTERN}$/
        # latitude, longitude
        [place.sub(/, *#{COORD_PATTERN}$/, ''), place.sub(/^#{COORD_PATTERN}, */, '')]
      else
        raise RuntimeError
      end
    rescue
      message = "location #{the_place} not found"
      if is_win
        message += ", please, verify that command 'bash' (from, e.g., " +
                   "http://unxutils.sourceforge.net) is in your PATH"
      end
      raise RuntimeError, message
    end
  end

  def Location.s_to_accuracy str
    case str.downcase
    when "world"   then 1
    when "country" then 3
    when "region"  then 6
    when "city"    then 11
    when "street"  then 16
    else raise ArgumentError, "unknown accuracy label '#{str}'"
    end
  end

  def accuracy_to_s
    case @accuracy
    when  1 then "world"
    when  3 then "country"
    when  6 then "region"
    when 11 then "city"
    when 16 then "street"
    else         @accuracy
    end
  end
end
