require 'cgi'

module HtmlTrawl 
   # A class to handle the patterns in blog post URLs:
   # site.com/category/post-slug
   # site.com/2012/01/12/post-slug
   # site.com/posts?q=2

   class BlogUrlFormatter 

      attr_reader :host, :path, :path_params, :query_params, :file_format

      PATH_PARAMS_REGEXES = {
         slug: /[\w\-\.]+/, # all alphanumeric and dashes and dots,
         category:  /[\w\-\.]+/, # all alphanumeric and dashes and dots,
         year: /199\d|20[01]\d/,
         month: /0?\d|1[0-2]/,
         day: /0?\d|1\d|2\d|3[01]/
      }

      def initialize(opts)
         mash = Hashie::Mash.new(opts)
         @path = mash.path
         @path_params = convert_to_path_params_segments(@path)
         @query_params = mash.query_params || [] # expects array
         @file_format = opts[:file_format].to_s.sub(/^\./, '') # strip leading dot, .html => html

         if d = mash.host
            @host = isolate_hostname(d)
         end
      end


      def matches?(url)
         uri_to_match = URI.parse(url)

         # guard clauses
         raise ArgumentError, "#{url} is not an absolute web address" unless uri_to_match.absolute?
         if has_host?
            return false if isolate_hostname(uri_to_match.host) != @host
         end


         # if a format has been specified, like .html, make sure it exists
         # and also, if @file_format is blank, makes sure that uri_to_match is also blank

         if has_file_format? 
            return false if isolate_file_format(uri_to_match.path) != @file_format
         end


         if has_query_params?
 
            return false if compare_query_parameters(uri_to_match.query) == false
         end

         do_segments_match = compare_path_segments( uri_to_match.path )

         return do_segments_match # if we get down this far
      end

      def has_host?
         @host.present?
      end

      # this returns true if blank, so it *enforces*
      # a url with no file format
      def has_file_format?
         @file_format
      end

      def has_query_params?
         @query_params.present?
      end

      private

      # expects @path_params to be populated in #initialize
      # compares each part of the given path to the @path_params
      # @path_params = ['blog', :category, :year, :month, :slug]
      # compared against: '/blog/puppies/2012/12/10/my-first-post'
      # 

      def compare_path_segments(some_path)
         segs_to_match = strip_bookend_slashes(some_path).split('/')

         return false if segs_to_match.count != @path_params.count 

         return @path_params.each_with_index.all? do |param, idx| 
            param_format = param.is_a?(Symbol) ? PATH_PARAMS_REGEXES[param] : Regexp.escape(param)
            is_match = segs_to_match[idx] =~ /#{param_format}/

            is_match
         end
      end

      def compare_query_parameters(query_str)
         q_params = CGI.parse(query_str)
         q_param_names = q_params.keys

         return false unless q_param_names.length == @query_params.length
         return false unless (q_param_names - @query_params).length == 0
         return true
      end

      def isolate_hostname(hostname)
         hostname.sub(%r{^http://}, '').sub(%r{^www\.}, '').split('/')[0].to_s
      end

      # converts "articles/:year/:month/:day" to an Array: ['articles', :year, :month, :day]
      def convert_to_path_params_segments(some_path)
         segs = strip_bookend_slashes(some_path).split('/')
         
         return segs.map{ |seg|
            if ms = seg.match(/(?<=:)\w+/)
                ms[0].to_sym
            else
               seg
            end
         }
      end


      # "something.html" is "html"
      def isolate_file_format(str)
         return str.slice(/(?<=\.)[a-z]+$/i).to_s
      end

      def strip_bookend_slashes(str)
         if str.present?
            return str.sub(%r{^/}, '').chomp('/')
         else
            ''
         end
      end

   end
end