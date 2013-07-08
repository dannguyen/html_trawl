require 'nokogiri'

module HtmlTrawl
	class Resolver

		attr_reader :parsed_html, :raw_html

		module ExportAsAttributes; end 
		include self::ExportAsAttributes
		# each class is responsible for implementing this

		def initialize(htmlnode)
         @raw_html = convert_nokogiri_to_html_text(htmlnode)
			@parsed_html = parse_content(htmlnode)
		end

		# return Nokogiri wrapper
	   def parse_content(ct)   
         return Resolver.parse_html_to_nokogiri(ct)
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


	   ## HTML specific


      def js_script_tags
         @js_tags ||= @parsed_html.css('script')
      end


      def css_script_tags
         @css_tags  ||= @parsed_html.css("link[href*='.css']")
      end

      def head_tag 
         @h_tag ||= @parsed_html.css('head')
      end


      def meta_tags
         @metas ||= head_tag.css('meta')
      end  

      def main_content
         @_main_content ||= remove_sidebar_content(@parsed_html)
      end



      def self.parse_html_to_nokogiri(ct)
         if ct.is_a? Nokogiri::XML::NodeSet
            return Nokogiri::HTML( ct.to_html )
         elsif ct.is_a?(Nokogiri::XML::Node) 
            return ct
         else  
           return Nokogiri::HTML(ct)
         end  
      end

      def self.convert_nokogiri_to_html_text(ct)
         if ct.is_a? Nokogiri::XML::NodeSet
            return ct.to_html
         elsif ct.is_a?(Nokogiri::XML::Node) 
            return ct.to_html
         elsif ct.is_a?(String)
           return ct
         else 
            raise ArgumentError, 'argument expected to be a string or Nokogiri object' 
         end  
      end

      private 


      # removes obvious sidebar content
      # creates and returns a stripped clone of that object
      def remove_sidebar_content(_parsed_page_object)
         stripped_page = _parsed_page_object.clone 
         aside_els = stripped_page.xpath("//*[contains(@class, 'sidebar') or contains(@class, 'widget') or contains(@id, 'widget') or contains(@id, 'sidebar')]" )
         aside_els.remove

         return stripped_page
      end


	end
end


Dir.glob(File.join( File.dirname(__FILE__), 'resolver', '*.rb')).each do |rbfile|
	require_relative rbfile 
end