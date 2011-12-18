# ruby
require 'escape'
require 'find'

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

  IMAGE_EXTENSIONS = [".gif", ".jpg", ".jpeg", ".png"] # lowercase
  VIDEO_EXTENSIONS = [".mpeg", ".mpg", ".avi"] # lowercase

end
