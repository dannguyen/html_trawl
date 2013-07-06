module HtmlTrawl
   class Resolution

      attr_reader :value, :html_text, :parsed_html, :relevancy

      def initialize(value, source_html, opts={})
         @value = value
         @parsed_html = Resolver.parse_html_to_nokogiri(source_html)
         @html_text = Resolver.convert_nokogiri_to_html_text(source_html)
      end


      private

      def determine_relevance!

      end

   end
end