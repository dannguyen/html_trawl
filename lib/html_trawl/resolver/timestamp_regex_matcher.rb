require 'hashie'

module HtmlTrawl
   class TimestampRegexMatcher 

    FULL_MONTHS_REGEX = %r{(?:January|February|March|April|May|June|July|August|September|October|November|December)}i
    ABBREV_MONTHS_REGEX = %r{(?:Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)\.?}i

    ALL_WRITTEN_MONTHS_REGEX = %r{#{FULL_MONTHS_REGEX}|#{ABBREV_MONTHS_REGEX}}

    DTX = {      
      hour: %r{(?<hour>\d{2})} ,
      minute: %r{(?<minute>\d{2})},
      second: %r{(?<second>\d{2})},
      timezone: %r{(?<timezone>(?:\+|-)\d{4})},
      month_abbrev: ABBREV_MONTHS_REGEX,
      month_full: FULL_MONTHS_REGEX,
      dash: %r{-},
      time_delim: %r{:},
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
      full_day: /\b(?<full_day>(?:3[0-1]|2\d|1\d|0[1-9]))\b/,            
      human_day: /\b(?<human_day>(?:3[0-1]|2\d|1\d|0?[1-9]))\b/
    }



    DTX[:date_delim] = %r{(?:#{DTX[:dash]}|\.|\/)} # 3/12/2000, 3.12.2000, 3-12-2000


    DTX[:program_full_date] = [/(?<year>#{DTX_YEAR[:full_year]})/, 
        /(?<month>#{DTX_MONTH[:full_month]})/,
        /(?<day>#{DTX_DAY[:full_day]})/].join(DTX[:dash].to_s)

#     DTX[:full_month], DTX[:full_day]].map{|t| t.to_s}.join(DTX[:dash].to_s)}/
  # TK later  DTX[:program_full_time] = %r{#{[DTX[:hour], DTX[:minute], DTX[:second]].join(DTX[:time_delim].to_s)}\s+#{DTX[:timezone]}}

    DATE_REGEXERS = Hashie::Mash.new({
          programmatic_standard: {
            regex: /#{DTX[:program_full_date]}/,
            value: 100,
            desc: 'A timestamp following programmatic standard: YYYY-MM-DD'
          },

          us_standard_numeric: {
            regex: /(?<month>#{DTX_MONTH[:human_numeral_month]})#{DTX[:date_delim]}(?<day>#{DTX_DAY[:human_day]})#{DTX[:date_delim]}(?<year>#{DTX_YEAR[:human_year]})/,
            value: 90,
            desc: 'M/D/YY'
          },

          us_written: {
            regex: /(?<month>#{DTX_MONTH[:human_written_month]})\s+(?<day>#{DTX_DAY[:human_day]})\s*,?\s*(?<year>#{DTX_YEAR[:written_year]})/,
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

    TIME_REGEXERS = Hashie::Mash.new({
          programmatic_standard: {
            regex: DTX[:program_full_time],
            value: 100,
            desc: 'A timestamp following programmatic standard, with HH:MM::SS TZ'
          }

        })

=begin
    DATETIME_REGEXEN = [

      /#{ALL_MONTHS_REGEX}\b\s+\d+\D{1,10}\d{4}/i,
      /(on\s+)?\d+\s+#{ALL_MONTHS_REGEX}\s+\D{0,10}\d+/i,
      /(on[^\d+]{1,10})\d+(th|st|rd)?.{1,10}#{ALL_MONTHS_REGEX}\b[^\d]{1,10}\d+/i,
      /\b\d{4}\-\d{2}\-\d{2}\b/i,
      /\d+(th|st|rd).{1,10}#{ALL_MONTHS_REGEX}\b[^\d]{1,10}\d+/i,
      /\d+\s+#{ALL_MONTHS_REGEX}\b[^\d]{1,10}\d+/i,
      /on\s+#{ALL_MONTHS_REGEX}\s+\d+/i,
      /#{ALL_MONTHS_REGEX}\s+\d+/i,
      /\d{4}[\.\/\-]\d{2}[\.\/\-]\d{2}/,
      /\d{2}[\.\/\-]\d{2}[\.\/\-]\d{4}/
    ]
=end

    def TimestampRegexMatcher.find_matches(org_str)
      # each match slices! the string, so we make a clone here
      # to avoid altering the original string
      str = org_str.clone 

      found_matches = DATE_REGEXERS.inject([]){ |arr, (regex_name, regex_type_hsh)|
        regex = regex_type_hsh[:regex]
        # get an array of MatchDatums
        matches = str.to_enum(:scan, regex).map{ r = Regexp.last_match; [r, r.begin(0), r.end(0)]}
        # note that @str is modified by slice each time
        matches.each do |mtch_and_pos|          
          mashie = Hashie::Mash.new
          mashie.regex = regex
          mashie.regex_name = regex_name.to_sym
          mashie.regex_value = regex_type_hsh[:value]
          
          mashie.regex_match, 
          mashie.regex_begin, 
          mashie.regex_end    =  mtch_and_pos 
          
          # iterate through each named group, e.g. :year, :month, :day
          _m = mashie.regex_match #convenience variable
          _m.names.each{ |name| mashie[name] = _m[name] }
          # slice! the string
          mashie.string_match = str.slice!(_m.regexp)

          arr << mashie
        end

        arr
      }

      return found_matches
    end


  end
end