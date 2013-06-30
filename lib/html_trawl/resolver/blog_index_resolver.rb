module HtmlTrawl
   class BlogIndexResolver < Resolver

      attr_reader :headline_element, :absolute_url

      MINIMUM_HEADLINE_ELEMENT_COUNT = 3

      def initialize(htmlnode, opts={})
         @parsed_html = parse_content(htmlnode)
         @raw_html = @parsed_html.to_html
         @headline_element = determine_headline_el
         @absolute_url = opts[:absolute_url]
      end

      def post_links
         @parsed_html.css(@headline_element)
      end

      def post_links_count
        post_links.count
      end


      # this is memoized
      def detect_post_element_xpaths

         if @_el_xpaths_arr.blank? # messy_TK

            # This should be a class constant
            post_lambdas = [
               ->(p_page){p_page.css('.hentry')},
               ->(p_page){ p_page.css('article')},
               ->(p_page){p_page.css('.post')}, 
               ->(p_page){p_page.xpath("//*[contains(@id, 'post-')]")}
            ]


            # results in an array of 2D elements
            @_el_xpaths_arr = post_lambdas.map do |lam|
               els = lam.call(@parsed_html)

               if els.count > 0
                  # if els.first = "/html/body/div[1]/div/div/article[1]"
                  # return something like ["/html/body/div[1]/div/div/article", 10]
                  [els.first.path.sub(/\[\d+\]$/, ''), els.count]
               else
                  nil
               end
            end
         end

         return @_el_xpaths_arr
      end 

      # convenience method
      # returns "/html/body/div[1]/div/div/article"
      def determine_post_element_xpath
         els = detect_post_element_xpaths
         els.first.andand[0]
      end

      # calls determine_post_element_xpath

      def collect_post_elements
         p_xpath = determine_post_element_xpath
         @parsed_html.xpath(determine_post_element_xpath) 
      end


      def determine_headline_el
         ## check to see if there are articles

         post_els = collect_post_elements
         
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

      module ExportAsAttributes; end
      include ExportAsAttributes


      private 

      


   end
end


Dir.glob(File.join( File.dirname(__FILE__), 'blog_index_resolvers', '*.rb')).each do |rbfile|
   #puts rbfile 
   require_relative rbfile 
end
