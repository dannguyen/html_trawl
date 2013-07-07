require 'hashie'

module HtmlTrawl
   class TimestampRegexMatcher 

    FULL_MONTHS_REGEX = %r{(?:January|February|March|April|May|June|July|August|September|October|November|December)}i
    ABBREV_MONTHS_REGEX = %r{(?:Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sept?|Oct|Nov|Dec)\.?}i

    ALL_WRITTEN_MONTHS_REGEX = %r{#{FULL_MONTHS_REGEX}|#{ABBREV_MONTHS_REGEX}}

    DTX = {      
      month_abbrev: ABBREV_MONTHS_REGEX,
      month_full: FULL_MONTHS_REGEX,
      dash: %r{-}  
      }

    DTX_YEAR = {
      full_year: /\b(?<full_year>\d{4})\b/,
      human_year: /\b(?<human_year>\d{2,4})\b/, 
      written_year: /(?:(?<full_year>\d{4})|(?<abbrev_year>'\d{2}))\b/
    }

    DTX_MONTH = {
      human_numeral_month: /\b(?<human_numeral_month>(?:1[0-2]|0?[1-9]))\b/,
      human_written_month: /\b(?<human_written_month>#{ALL_WRITTEN_MONTHS_REGEX})/,
      full_month: /\b(?<full_month>(?:1[0-2]|0[1-9]))\b/
    }

    DTX_DAY = {
      full_day: /\b(?<full_day>(?:3[0-1]|2\d|1\d|0[1-9]))/,            
      human_day: /\b(?<human_day>(?:3[0-1]|2\d|1\d|0?[1-9]))/,
      written_day: /\b(?<written_day>\d?(?:1(?:st)?|2(?:nd)?|3(?:rd)?|[4567890](?:th)?))/
    }



    DTX[:date_delim] = %r{(?:#{DTX[:dash]}|\.|\/)} # 3/12/2000, 3.12.2000, 3-12-2000


    DTX[:iso_full_date] = [/(?<year>#{DTX_YEAR[:full_year]})/, 
        /(?<month>#{DTX_MONTH[:full_month]})/,
        /(?<day>#{DTX_DAY[:full_day]})/].join(DTX[:dash].to_s)


    DATE_REGEXERS = Hashie::Mash.new({
          iso_standard: {
            regex: /#{DTX[:iso_full_date]}/,
            value: 100,
            desc: 'A timestamp following iso standard: YYYY-MM-DD'
          },

          us_standard_numeric: {
            regex: /(?<month>#{DTX_MONTH[:human_numeral_month]})#{DTX[:date_delim]}(?<day>#{DTX_DAY[:human_day]})#{DTX[:date_delim]}(?<year>#{DTX_YEAR[:human_year]})/,
            value: 90,
            desc: 'M/D/YY'
          },

          us_written: {
            regex: /(?<month>#{DTX_MONTH[:human_written_month]})\s+(?<day>#{DTX_DAY[:written_day]})\s*,?\s*(?<year>#{DTX_YEAR[:written_year]})/,
            value: 85,
            desc: 'Jan. 12 1991'
          },

=begin
          europe_standard_numeric: {
            regex: /#{DTX[:human_day]}#{DTX[:date_delim]}#{DTX[:human_numeral_month]}#{DTX[:date_delim]}#{DTX[:human_year]}/,
            value: 85,
            desc: 'Jan'
          },


          europe_written: {

          }
=end
        })


    DTX_TIME = {
      hour: %r{(?<hour>\d{2})} ,
      minute: %r{(?<minute>\d{2})},
      second: %r{(?<second>\d{2})},
      timezone: %r{(?<timezone>(?:\+|-)\d{4})},



    }

    DTX_HOUR = {
      iso: /(?<iso_hour>(?:[01]\d|2[0-3]))/
    }

    DTX_MINUTE = {
      iso: /(?<iso_minute>[0-5]\d)/
    }

    DTX_SECOND = {
      iso: /(?<iso_second>[0-5]\d)/
    }


    DTX_TZ = {
      iso: /(?<iso_timezone>(?:\+|-)\d{2}:?\d{2})/
    }

  # TK later  DTX[:iso_full_time] = %r{#{[DTX[:hour], DTX[:minute], DTX[:second]].join(DTX[:time_delim].to_s)}\s+#{DTX[:timezone]}}


    TIME_REGEXERS = Hashie::Mash.new({
          iso_standard: {
            regex: /(?<hour>#{DTX_HOUR[:iso]}):(?<minute>#{DTX_MINUTE[:iso]}):(?<second>#{DTX_SECOND[:iso]})(?<timezone>#{DTX_TZ[:iso]})/,
            value: 100,
            desc: 'A timestamp following iso standard, with HH:MM:SS+TZ'
          }
        })

    def TimestampRegexMatcher.find_regex_by_type(org_str, regex_array)
      # each match slices! the string, so we make a clone here
      # to avoid altering the original string
      str = org_str.clone 

      all_found_matches = regex_array.inject([]){ |arr, (regex_name, regex_type_hsh)|
        regex = regex_type_hsh[:regex]
        # get an array of MatchDatums
        this_regex_matches = str.to_enum(:scan, regex).map{ r = Regexp.last_match; [r, r.begin(0), r.end(0)]}
        # note that @str is modified by slice each time

        this_regex_matches.each do |mtch_and_pos|          
          mashie = Hashie::Mash.new
          mashie.regex = regex
          mashie.regex_name = regex_name.to_sym
          mashie.regex_value = regex_type_hsh[:value]
          
          mashie.regex_match, 
          mashie.regex_begin, 
          mashie.regex_end    =  mtch_and_pos           

          _m = mashie.regex_match #convenience variable
          mashie.string_match = _m.to_s

          # iterate through each named group, e.g. :year, :month, :day
          _m.names.each{ |name| mashie[name] = _m[name] }
         

          # modify the (cloned) receiver string, replace the match with a series of DTK so that
          # the date string isn't matched successive times by looser date standards
          m_length = mashie.string_match.length # convenience
          str = str.sub(regex, ('DTK' * (m_length / 3.0).ceil)[0..(m_length-1)] )

          arr << mashie
        end

        arr
      }

      return all_found_matches
    end

    def TimestampRegexMatcher.find_dates(org_str)
      TimestampRegexMatcher.find_regex_by_type(org_str, DATE_REGEXERS)
    end

    def TimestampRegexMatcher.find_times(org_str)
      TimestampRegexMatcher.find_regex_by_type(org_str, TIME_REGEXERS)
    end



  end
end