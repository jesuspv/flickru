# gems
require 'colorize'
require 'simplecov'
SimpleCov.coverage_dir(File.join('var', 'cov'))
SimpleCov.start # should be before loading flickru code!
# flickru
require 'flickru'

describe Flickru do
  it "accents work" do
    Flickru.flickru "var/ts/tc_accents"
  end

  it "different accuracies work case-insensitively" do
    Flickru.flickru "var/ts/tc_accuracies"
  end

  it "several collections, several sizes" do
    Flickru.flickru "var/ts/tc_collections"
  end

  it "setting date-taken metadata from Exif metadata if existing" do
    Flickru.flickru "var/ts/tc_date_taken"
  end

  it "various filetypes available, skipping garbage" do
    Flickru.flickru "var/ts/tc_filetypes"
  end

  it "ignoring location if photo is geotagged" do
    Flickru.flickru "var/ts/tc_geotagging"
  end

  it "large files work" do
    Flickru.flickru "var/ts/tc_large_files"
  end

  it "locations can be specified in many ways" do
    Flickru.flickru "var/ts/tc_locations"
  end

  it "leading and trailing whitespaces are removed" do
    Flickru.flickru "var/ts/tc_whitespaces"
  end

  it "processing by alphabetical order (by filename)" do
    Flickru.flickru "var/ts/tc_sorting"
  end

  after(:all) do
    puts "\nRemember to delete the testing files that have been just uploaded to your Flickr's collection 'Testing Collection*'.".red
  end
end
