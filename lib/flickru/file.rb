# ruby
require 'find'
# gems
require 'escape'
require 'exifr'

class File

  def File.find dir
    found = Array.new
    Find.find dir do |file|
      if File.directory? file
        if File.basename(file)[0] == ?.
          Find.prune # don't look any further into this directory
        else
          next
        end
      else
        if yield file
          found << file
        end
      end
    end
    found
  end

  def File.image? file
    IMAGE_EXTENSIONS.include? File.extname(file).downcase
  end

  def File.video? file
    VIDEO_EXTENSIONS.include? File.extname(file).downcase
  end

  def File.duration video
    s = `#{Escape.shell_command ["ffmpeg", "-i", video]} 2>&1`
    if s =~ /Duration: ([\d][\d]):([\d][\d]):([\d][\d]).([\d]+)/
      hours     = $1.to_i
      mins      = $2.to_i
      seconds   = $3.to_i
      # fractions = ("." + $4).to_f

      hours * 60 * 60 + mins * 60 + seconds
    else
      0
    end
  end

  def File.date_taken file
    attempt = 1
    begin
       case attempt
       when 1 then EXIFR::JPEG.new(file).date_time_original.strftime "%y-%m-%d %H:%M:%S"
       when 2 then EXIFR::TIFF.new(file).date_time_original.strftime "%y-%m-%d %H:%M:%S"
       else nil
       end
    rescue
       attempt += 1
       retry
    end
  end

  def File.geotagged? file
    attempt = 1
    begin
       case attempt
       when 1 then
          hash = EXIFR::JPEG.new(file).to_hash
       when 2 then
          hash = EXIFR::TIFF.new(file).to_hash
       else return false
       end
    rescue
       puts $!
       attempt += 1
       retry
    end

    lat     = hash.key? :gps_latitude
    lon     = hash.key? :gps_longitude
    lat_ref = hash.key? :gps_latitude_ref
    lon_ref = hash.key? :gps_longitude_ref

    lat and lon and lat_ref and lon_ref
  end

  def File.human_readable_size file_size
    if file_size < 1000
      file_size.to_s + " bytes"
    elsif file_size < 1000000
      (file_size / 1000).to_s + "KB"
    elsif file_size < 1000000000
      (file_size / 1000000).to_s + "MB"
    else
      (file_size / 1000000000).to_s + "GB"
    end
  end

private

  IMAGE_EXTENSIONS = [".gif", ".jpg", ".jpeg", ".png", ".tiff"] # lowercase
  VIDEO_EXTENSIONS = [".mpeg", ".mpg", ".avi"] # lowercase

end
