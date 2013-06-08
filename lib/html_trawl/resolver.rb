module HtmlTrawl
	module Resolver
	end
end


Dir.glob(File.join( File.dirname(__FILE__), 'resolver', '*.rb')).each do |rbfile|
	require_relative rbfile 
end