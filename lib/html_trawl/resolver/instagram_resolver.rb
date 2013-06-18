module HtmlTrawl
  class InstagramResolver < Resolver

    INSTAGRAM_URL_REGEXES = {
      profile: /https?:\/\/(?:www\.)?instagram\.com\/([^\/]+)\/?$/
    }

    INSTAGRAM_PATTERNS = [
      [ 
        :href, ->(p_content) do 
          p_content.css('a').map{|a| a['href'].andand.match(INSTAGRAM_URL_REGEXES[:profile]).andand[1] }.compact
        end
      ]
    ]


    module ExportAsAttributes

      def instagram_accounts
        @_instagram_accounts ||= InstagramResolver.detect_instagram_accounts(@parsed_html)
      end

      # for now, just pick the first
      def likely_instagram_account
        instagram_accounts.first.andand.first
      end

    end
    include ExportAsAttributes




#### CLASS METHODS


  def self.parse_instagram_handle(url)
       if handle = url.strip.match(INSTAGRAM_URL_REGEXES[:profile])
          return handle[1]
       end
  end

    def self.detect_instagram_accounts(parsed_content)
      accounts_arr = []

      # each pattern type returns a 1-D array

      INSTAGRAM_PATTERNS.each do |f_arr|
        pattern_type, foo = f_arr 

        
        foo.call(parsed_content).each do |val|
          accounts_arr << [val, pattern_type]
        end
      end

      return accounts_arr
    end

  end
end