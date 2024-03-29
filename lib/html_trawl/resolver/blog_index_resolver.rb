module HtmlTrawl
   class BlogIndexResolver < Resolver

      attr_reader :absolute_url


      def initialize(htmlnode, opts={})
         @parsed_html = parse_content(htmlnode)
         @raw_html = @parsed_html.to_html
         
         @absolute_url = opts[:absolute_url]
      end


      def headline_element
         @_headline_element ||= determine_headline_el
      end

      # read each post for headline links, keep only unique ones, so strip out any fragments

      def post_urls
         arr_hrefs = []
         collect_post_elements.each do |element|
            # there should only be one headline link per post
            if link = element.search( headline_element ).first 
               uri = URI.parse link['href']
               uri.fragment = nil
               arr_hrefs << uri.to_s 
            end
         end

         return arr_hrefs
      end

      def post_urls_count
        post_urls.count
      end


      # this is memoized
      def detect_post_element_xpaths

         if @_el_xpaths_arr.blank? # messy_TK

            # This should be a class constant
            post_lambdas = [
               ->(p_page){p_page.css('.hentry')},
               ->(p_page){ p_page.css('article')},
               ->(p_page){p_page.xpath("//*[contains(@id, 'post-')]")},
               ->(p_page){p_page.css('.post')}
            ]


            # results in an array of 2D elements
            @_el_xpaths_arr = post_lambdas.map do |lam|
               els = lam.call(@parsed_html)
               if els.count > 0
                  # if els.first = "/html/body/div[1]/div/div/article[1]"
                  first_el = els.first

                  # return something like ["/html/body/div[1]/div/div/article", 10, first_el]
                  [first_el.path.sub(/\[\d+\]$/, ''), els.count, first_el]
               else
                  nil
               end
            end.compact

            ## ugly way of filtering out elements that are children of other qualifying elements
            ## e.g. if structure is article > div.hentry
            ## use article

            all_first_els = @_el_xpaths_arr.map{|a| a[2]}
            @_el_xpaths_arr = @_el_xpaths_arr.reject do |arr|
               first_el = arr[2]

               all_first_els.any?{|a| first_el.ancestors.include?(a) }
            end
         end

         

         return @_el_xpaths_arr
      end 

      # convenience method
      # returns "/html/body/div[1]/div/div/article"
      # TK: Major bug: this will capture siblings with the same tag name, so class name needs to 
      # be specified
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
         if el = els.first  
            return [el.parent, el].compact.map{|e| e.node_name}.join(' > ')
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
