require "html_trawl/version"
require 'andand'

module HtmlTrawl
  # Your code goes here...
end


require_relative 'html_trawl/resolver'

Dir.glob(File.join( File.dirname(__FILE__), 'html_trawl', '**', '*.rb')).each do |rbfile|
   require_relative rbfile 
end
