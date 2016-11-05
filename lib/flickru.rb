# ruby
require 'set'
# gems
require 'rubygems'
require 'bundler/setup'
# flickru
require 'flickru/file'
require 'flickru/flickr'
require 'flickru/journey'
require 'flickru/printer'
require 'flickru/version'

FlickRaw.api_key       = "aaf7253e0f88f03aa59f9d3074bf2d4b"
FlickRaw.shared_secret = "138ee268f76cd780"

module Flickru

def Flickru.usage
  filename = File.basename __FILE__
  Printer.show "#{filename} -- Flickr upload command-line automator\n"
  Printer.show "usage: #{filename} [<options>] <photo directory>\n"
  Printer.show "example: #{filename} my_photos\n"
  Printer.show "options:\n"
  Printer.show "  -h, --help      show help\n"
  Printer.show "  -r, --rm        delete each photo when uploaded\n"
  Printer.show "  -v, --version   show version\n"
  readme = File.expand_path(File.join(File.dirname(__FILE__), '..', 'README'))
  Printer.show "\n#{IO.read(readme)}"
end

def Flickru.die code, message
  Printer.error "error:#{code}: #{message}"
  exit 1
end

def Flickru.config_filename
  File.join ENV['HOME'], "." + File.basename(__FILE__, File.extname(__FILE__)) + "rc"
end

def self.read_config
  file = File.open config_filename, "r"
  token, secret = file.readlines.map { |line| line.sub(/\#.*$/, '').strip } # remove line comments
  file.close
  Flickr.access token, secret
rescue
  raise RuntimeError, "unable to open configuration file #{config_filename}"
end

def Flickru.write_config token, secret
    Printer.show "writing configuration file #{config_filename}... "
  if File.exists? config_filename
    file = File.new config_filename, "w"
  else
    file = File.open config_filename, "w"
  end
  file.puts "#{token} \# access token"
  file.puts "#{secret} \# access secret"
  file.close
    Printer.success
rescue
  raise RuntimeError, "unable to write configuration file #{config_filename}"
end

def self.flickru rmFlag, photo_dir
  begin
    Flickru.read_config
  rescue RuntimeError
    token, secret = Flickr.login
    write_config token, secret
  end

  # upload and classify
  photos       = File.find(photo_dir) {|f| File.image? f or File.video? f }
  total_size   = photos.reduce(0) {|t,p| t + File.size(p)}
  Printer.info "#{File.human_readable_size total_size} to upload"
  journey      = Journey.new total_size
  photoset_ids = Set.new
  photos.sort.each do |photo|
      Printer.info "file '#{File.join File.basename(File.dirname(photo)), File.basename(photo)}' under process"
    begin
      retries ||= 0
      photo_id = Flickr.upload_photo photo
      photoset_ids << Flickr.classify(photo, photo_id)
    rescue ArgumentError || Errno::ENOENT || Errno::EAGAIN || Errno::EPIPE || FlickRaw::FailedResponse
      if (retries += 1) < 3
        Printer.warn "retrying #{photo}: #{$!}"
        sleep (Math.exp retries)
        retry
      else
        Printer.failure "#{photo}: #{$!}"
      end
    end
    journey.take File.size(photo)
    Printer.info "#{File.human_readable_size journey.progress} uploaded, " +
                 "#{File.human_readable_size journey.distance} remaining. " +
                 "ETA: #{Printer.human_readable_seconds journey.eta}" if journey.eta > 0
    File.delete photo if rmFlag
  end

  photoset_ids.each do |set_id|
    Flickr.arrangePhotos set_id
  end

  Printer.ask "Please, review whether: any of your photos need to be rotated,\n" +
              "  better primary photos for your sets have been uploaded,\n" +
              "  and better collection mosaics can be randomised."
rescue Exception => e
  file_line = e.backtrace.empty? ? "?" : e.backtrace[0].split(':')
  Flickru.die "#{File.basename file_line[-3]}:#{file_line[-2]}", e.message
end

end # module Flickru
