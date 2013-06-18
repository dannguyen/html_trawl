require 'nokogiri'

module HtmlTrawl
	class Resolver

		attr_reader :parsed_html


		module ExportAsAttributes; end 
		include self::ExportAsAttributes
		# each class is responsible for implementing this

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

	   def exportable_attributes
	   	klass = self.class
	   	if klass.const_defined?(:ExportAsAttributes)
			   klass::ExportAsAttributes.public_instance_methods
			else
				return []
			end
		end

	   def to_hash
	   	hsh = Hashie::Mash.new(resolved_timestamp: Time.now)
	   	exportable_attributes.inject(hsh) do |h, foo|
	   		h[foo] = self.send foo
	   		h
	   	end		   
		   return hsh
	   end

	end
end


Dir.glob(File.join( File.dirname(__FILE__), 'resolver', '*.rb')).each do |rbfile|
	require_relative rbfile 
end