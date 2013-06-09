require 'nokogiri'

module HtmlTrawl
	class Resolver

		attr_reader :parsed_html

		def initialize(htmlnode)
			@parsed_html = parse_content(htmlnode)
		end


		# return Nokogiri wrapper
	   def parse_content(ct)   
	      if ct.is_a? Nokogiri::XML::NodeSet
	         return Nokogiri::HTML( ct.to_html )
	      elsif ct.is_a?(Nokogiri::XML::Node) 
	         return ct
	      else  
	        return Nokogiri::HTML(ct)
	      end  
	   end




	end
end


Dir.glob(File.join( File.dirname(__FILE__), 'resolver', '*.rb')).each do |rbfile|
	require_relative rbfile 
end