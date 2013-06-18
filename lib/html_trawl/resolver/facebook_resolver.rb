module HtmlTrawl
  class FacebookResolver < Resolver

    FACEBOOK_URL_REGEXES = {
      profile: /https?:\/\/(?:www\.)?facebook\.com\/([^\/]+)\/?$/
    }

    FACEBOOK_PATTERNS = [
      [ 
        :href, ->(p_content) do 
          p_content.css('a').map{|a| a['href'].match(FACEBOOK_URL_REGEXES[:profile]).andand[1] }.compact
        end
      ]
    ]


    module ExportAsAttributes

      def facebook_accounts
        @_facebook_accounts ||= FacebookResolver.detect_facebook_accounts(@parsed_html)
      end

      # for now, just pick the first
      def likely_facebook_account
        facebook_accounts.first.andand.first
      end
    end
    include ExportAsAttributes






#### CLASS METHODS


  def self.parse_facebook_handle(url)
       if handle = url.strip.match(FACEBOOK_URL_REGEXES[:profile])
          return handle[1]
       end
  end

    def self.detect_facebook_accounts(parsed_content)
      accounts_arr = []

      # each pattern type returns a 1-D array

      FACEBOOK_PATTERNS.each do |f_arr|
        pattern_type, foo = f_arr 

        
        foo.call(parsed_content).each do |val|
          accounts_arr << [val, pattern_type]
        end
      end

      return accounts_arr
    end

  end
end