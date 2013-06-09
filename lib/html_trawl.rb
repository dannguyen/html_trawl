require "html_trawl/version"
require 'andand'

module HtmlTrawl
  # Your code goes here...
end


require_relative 'html_trawl/resolver'

# include helpers 
['helpers', 'mixins'].each do |subdir|

	Dir.glob(File.join( File.dirname(__FILE__), 'html_trawl', subdir, '*.rb')).each do |rbfile|
		require_relative rbfile 
	end

end
