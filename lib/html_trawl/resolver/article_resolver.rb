require 'pismo'
require 'readability'
require 'hashie'

module HtmlTrawl
	class ArticleResolver < Resolver


		def initialize(htmlnode)
			@parsed_html = parse_content(htmlnode)
			@raw_html = @parsed_html.to_html
			_set_content_hash!
		end

			# returns a String of whitelisted HTML from either Pismo or Readability, which ever is better
	   def content
	      @content_hash[@parsing_library].content 
	   end

	   def content_text
	      @content_hash[@parsing_library].text
	   end


	   def content_parsed
	      @_content_nodes ||= Nokogiri::HTML(self.content)
	   end

	   def content_links
	      # ignore blank/anchor links
	      # todo: move this to convert_relative_links

	      @_content_links ||= content_parsed.css('a').reject{ |a| 
	         href = a['href']
	         href.blank? || href =~ /^#/ 
	      }
	   end

	   def content_words 
	      @content_words ||= content_text.split /\W+/
	   end

	   def content_word_count
	      content_words.count
	   end

	   def content_image_nodes
	      @content_hash['Readability'].document.images
	   end



	### meta stuff

	   def content_published_timestamp
	      # use manual parsing here

	      time_texts = []
	      # first, let's check for <time> elements with .entry/.publish class
	      time_texts += @parsed_html.css('time').sort_by{|c| c['class'] =~ /entry|publish/ ? 1 : 0}.to_a.map{ |tnode| 
	         Chronic.parse(tnode['datetime'] || tnode.text, context: :past)
	      }

	      # second, let's check for entry meta tags that contain date like texts:
	      if time_texts.tap{|t| t.compact!}.empty?
	         nodes = @parsed_html.xpath('//*[contains(@class, "date")]|//*[contains(@class, "time")]')
	         time_texts += nodes.map{|t| Chronic.parse(t.text, context: :past) } 
	      end

	      # third, let's check for all meta type tags
	      if time_texts.tap{|t| t.compact!}.empty?
	         meta_nodes = @parsed_html.xpath('//*[contains(@class, "meta")]')
	         time_texts += meta_nodes.map{|t| Chronic.parse(t.text, context: :past)  }
	      end


	      if main_time_node = time_texts.tap{|t| t.compact!}.first
	         #t = main_time_node['datetime'] || main_time_node.text
	         timeval = main_time_node
	      else
	         timeval = @content_hash['Pismo'].document.datetime
	      end

	      return timeval
	   end

	   def content_title
	      @content_hash['Pismo'].document.title 
	   end

	   def content_description
	      @content_hash['Pismo'].document.description
	   end





		private
		def _set_content_hash!
	      @content_hash = Hashie::Mash.new{|h,k| h[k] = Hashie::Mash.new }
	      @readability_doc = Readability::Document.new( @raw_html, tags: %w(div p a img), attributes: %w(href src), remove_empty_nodes: false)
	      @content_hash['Readability'] = {
	         document: @readability_doc, 
	         content: @readability_doc.content      
	      }
	      @content_hash['Readability'].text = Sanitize.clean( @content_hash['Readability'].content).strip

	      @pismo_doc = Pismo::Document.new(@raw_html)
	      @content_hash['Pismo'] = {
	         document: @pismo_doc, 
	         content: @pismo_doc.html_body         
	      }
	      @content_hash['Pismo'].text = Sanitize.clean( @content_hash['Pismo'].content).strip


	      ## lets decide which parsing library to use
	      ## Pismo has some nice features, when it works

	      @parsing_library = nil 
	      if @content_hash['Pismo'].text.length < 20 || ( @content_hash['Readability'].text.length - @content_hash['Pismo'].text.length) > 200  
	         @parsing_library = "Readability"
	      else
	         @parsing_library = "Pismo"
	      end
		end

	end
end
