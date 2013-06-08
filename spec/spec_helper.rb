
require 'html_trawl'


include HtmlTrawl

module PageFixtures
   FIXTURES_DIR = File.expand_path File.dirname(__FILE__) + '../../spec/fixtures/'

   extend self

   def load(page_sym)
      fpath = File.join FIXTURES_DIR, page_sym.to_s.downcase
      open(fpath){|f| f.read}
   end
end


RSpec.configure do |config|
    config.filter_run_excluding :skip => true

  
  config.before(:each) do

#
  end

  config.after(:each) do
#
  end
end






