require 'pismo'
require 'readability'
require 'hashie'

module HtmlTrawl
   class MetaResolver < Resolver

      def initialize(htmlnode)
         @parsed_html = parse_content(htmlnode)
         @raw_html = @parsed_html.to_html
      end


 
      module ExportAsAttributes
         # prefer og to standard meta
         [:title, :description, :keywords, :keywords_array, :image].each do |foo_sym| 
            define_method foo_sym do
               og_foo = "og_#{foo_sym}" 
               og_val = send(og_foo) if respond_to?(og_foo)
               meta_foo = "meta_#{foo_sym}"
               meta_val = send(meta_foo) if respond_to?(meta_foo)

               return og_val || meta_val
            end
         end
      end
      include ExportAsAttributes

      def meta_title
         head_tag.css('title').text
      end

      def meta_description
         extract_content_attr( meta_tags.xpath("//meta[@name='description']")) 
      end

      def meta_keywords
         extract_content_attr( meta_tags.xpath("//meta[@name='keywords']"))
      end

      def meta_keywords_array
         meta_keywords.split(',').map{|m| m.gsub(/\s/, ' ').strip } if meta_keywords.present?
      end

      ### oggy oggy oggie

      OG_TAGS = %w(title description image)

      OG_TAGS.each do |ogtag|
         define_method "og_#{ogtag}" do 
            extract_content_attr head_tag.xpath("//meta[@property='og:#{ogtag}']")
         end
      end


      private

      # extracts the actual meta content from a Nokogiri node list 
      def extract_content_attr(nodes)
         nodes.first.andand['content']
      end


   end
end