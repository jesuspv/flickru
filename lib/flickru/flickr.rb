# gems
require 'flickraw'
require 'unicode_utils'
# flickru
require 'flickru/file'
require 'flickru/location'
require 'flickru/printer'
require 'flickru/ruby'

module Flickr

  def self.access token, secret
    flickr.access_token  = token
    flickr.access_secret = secret
  end

  def self.login
    token    = flickr.get_request_token
    auth_url = flickr.get_authorize_url token['oauth_token'], :perms => 'write' # read, delete
    Printer.ask  "Open this URL in your process to complete the authentication process:\n#{auth_url}\n"
    Printer.enter "Copy the number given when you complete the process here"

    verify = STDIN.gets.strip
    flickr.get_access_token token['oauth_token'], token['oauth_token_secret'], verify

    login = flickr.test.login
      Printer.show "you are now authenticated as #{login.username} " +
                   "with token #{flickr.access_token} and secret #{flickr.access_secret}\n"
    [flickr.access_token, flickr.access_secret]
  end

  def self.size_limit_exceeded? file
    if File.image? file
      File.size(file).to_i > 20000000 # 20MB
    elsif File.video? file
      File.size(file).to_i > 500000000 # 500MB
    else
      raise ArgumentError, "#{file}: not an image nor a video"
    end
  end

  def self.upload_photo photo
    Ruby.assert("not Flickr.size_limit_exceeded?(photo)") \
               { not Flickr.size_limit_exceeded?(photo) }

      if File.duration(photo) > 90 # seconds
        description = "video duration (#{File.duration photo} sec) exceeds Flickr's duration limit (90 sec)."
        Printer.warn description
        description = "This " + description + "\nDownload original file to play full video."
      end

    date = File.date_taken photo
    if date.nil? then date = File.mtime(photo).strftime "%y-%m-%d %H:%M:%S" end

    loc  = Location.new photo
      Printer.show "uploading as " +
                   (loc.nil? ? "\"#{loc.name.black}\" (no location given)" : loc.to_s.black) +
                   " taken on #{date}... "
    begin
      id = flickr.upload_photo photo, :title => UnicodeUtils.nfkc(loc.name), :is_public => 0,
                                      :description => description, :tags => UPLOADING_TAG,
                                      :is_friend => 1, :is_family => 1, :safety_level => 1, # Safe,
                                      :content_type => 1, :hidden => 2 # Photo/Video
# TODO visibility MAY be configurable
      req = flickr.photos.getNotInSet(:extras => 'tags').to_hash["photo"][-1]
    rescue Timeout::Error
      Flickru.read_config
      req = flickr.photos.getNotInSet(:extras => 'tags').to_hash["photo"][-1]
      if req.nil?
        raise RuntimeError, "unrecoverable timeout due to large file size"
      else
        if req.to_hash["tags"] != UPLOADING_TAG
          raise RuntimeError, "unrecoverable timeout due to large file size"
        end
        id = req.to_hash["id"]
      end
    end
    flickr.photos.setTags :photo_id => id, :tags => ''

    flickr.photos.setDates :photo_id => id, :date_taken => date
    flickr.photos.setPerms :photo_id => id, :is_public => 0,
                           :is_friend => 1, :is_family => 1, # again! (mandatory) :P
                           :perm_comment => 1, :perm_addmeta => 0
# TODO permission MAY be configurable
    if not loc.nil?
      flickr.photos.geo.setLocation :photo_id => id, :lat => loc.latitude,
                                    :lon => loc.longitude, :accuracy => loc.accuracy                             
    end

    Printer.success

    return id
  end

# TODO face tagging (http://developers.face.com http://github.com/rociiu/face) MAY be available

  def self.classify photo_path, photo_id
    set_title  = File.basename(File.dirname(File.dirname(photo_path)))
    set_id     = Flickr.photoset_id set_title
    photo_name = File.basename(photo_path, File.extname(photo_path))
    if set_id
        Printer.show "classifying #{photo_name.black} under set #{set_title}... "
      flickr.photosets.addPhoto :photoset_id => set_id, :photo_id => photo_id
        Printer.success
    else
        Printer.show "creating photoset #{set_title.black} with primary photo #{photo_name}... "
      response = flickr.photosets.create :title => set_title, :primary_photo_id => photo_id
      set_id   = response.to_hash["id"]
        Printer.success

# TODO new photosets MAY be included in some collection. Unfortunately, collections cannot be yet modified by the Flickr API.
# TODO photosets MAY be ordered alphabetically (flickr.photosets.orderSets API function)
      Printer.ask "Please, choose yourself a better primary photo for this photoset,\n" +
                  "  order your photosets for positioning this new addition,\n" +
                  "  and include the new photoset in some collection."
    end

    return set_id
  end

  def self.arrangePhotos set_id
    set_title = flickr.photosets.getInfo(:photoset_id => set_id).to_hash["title"]

      Printer.show "arranging photos in photoset #{set_title.black} by date taken (older first)... "
    response = flickr.photosets.getPhotos(:photoset_id => set_id, :extras => "date_taken").to_hash
    if response["pages"] == 1
      photos    = response["photo"].sort! { |a,b| a["datetaken"] <=> b["datetaken"] } # older first
      photo_ids = photos.map { |photo| photo["id"].to_s }
      if not photo_ids.empty?
        photo_ids = photo_ids[1,photo_ids.length].reduce photo_ids[1] do |s,i| s + ',' + i end
        flickr.photosets.reorderPhotos :photoset_id => set_id, :photo_ids => photo_ids
      end
        Printer.success
    else
        Printer.failure "photoset #{set_title} has more than #{response['perpage']} photos."
      Printer.ask "Please, arrange by date taken (older first) within Flickr Organizr."
    end
  end

  def self.photoset_id set_title
    flickr.photosets.getList.each do |photoset|
      if photoset["title"] == set_title
        return photoset["id"]
      end
    end

    return nil
  end

private

  UPLOADING_TAG = "uploading"

end
