module HtmlTrawl
   class BlogIndexResolver < Resolver

      attr_reader :headline_element, :absolute_url

      MINIMUM_HEADLINE_ELEMENT_COUNT = 3

      def initialize(htmlnode, opts={})
         @parsed_html = parse_content(htmlnode)
         @raw_html = @parsed_html.to_html
         @headline_element = determine_headline_el(@parsed_html)
         @absolute_url = opts[:absolute_url]
      end

      def post_links
         @parsed_html.css(@headline_element)
      end

      def post_links_count
        post_links.count
      end


      module ExportAsAttributes
         
      end
      include ExportAsAttributes
      

      private 
      def determine_headline_el(parsed_page)
         ## check to see if there are articles
         post_els = parsed_page.xpath("//*[self::div[contains(@class,'article') or contains(@class ,'post') or contains(@id, 'post') or contains(@class, 'entry')] or self::article]")
         
         link_count = ['h1 > a', 'h2 > a', 'h3 > a', 'h4 > a'].inject({}) do |hsh, el|
            hsh[el] = post_els.search(el)
            hsh
         end.collect

         sorted_occ = link_count.sort_by{|r| r[1].count}.reverse
         el_name, els = sorted_occ.first

         # build up el name with parent
         if el_name && els.count > MINIMUM_HEADLINE_ELEMENT_COUNT
            el = els.first 
            return [el.parent.parent, el.parent, el].compact.map{|e| e.node_name}.join(' > ')
         end
      end


   end
end


Dir.glob(File.join( File.dirname(__FILE__), 'blog_index_resolvers', '*.rb')).each do |rbfile|
   #puts rbfile 
   require_relative rbfile 
end
