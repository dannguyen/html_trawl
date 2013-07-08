module HtmlTrawl
  class TimestampResolver < Resolver


    def initialize(str, opts={})

      super(str)      

      @raw_text = @parsed_html.text 
      @date_matches = TimestampRegexMatcher.find_dates(@raw_text)
      @time_matches = TimestampRegexMatcher.find_times(@raw_text)

      @datetime_objects = TimestampRegexMatcher.pair_datetimes(@date_matches, @time_matches)


    end 




  end
end