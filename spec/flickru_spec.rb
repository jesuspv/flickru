# gems
require 'colorize'
require 'simplecov'
SimpleCov.coverage_dir(File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'var', 'cov')))
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

  it "various filetypes available, skipping garbage" do
    Flickru.flickru "var/ts/tc_filetypes"
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

  after(:all) do
    puts "\nRemember to delete the testing files that have been just uploaded to your Flickr's collection 'Testing Collection*'.".red
  end
end
