module HtmlTrawl
  class TwitterResolver < Resolver

    TWITTER_URL_REGEXES = {
         twitter_profile: /https?:\/\/(?:www\.)?twitter\.com\/(?!share\b)(\w+)(?=\/?$)/,
         follow_text: /me|follow|my|I'm/i 
      }


    module ExportAsAttributes


      def twitter_accounts
        @_twitter_accounts ||= TwitterResolver.detect_twitter_accounts(@parsed_html)
      end


      def likely_twitter_account
         return if twitter_accounts.empty?

         if t = twitter_accounts.rassoc('twitter-follow-button')
            return t[0]
         elsif t = twitter_accounts.rassoc('link-text-follow')
            return t[0]
         else 
            vals = twitter_accounts.inject(Hash.new{|h,k| h[k] = 0}){ |hsh, row|
               hsh[(row[0])] += 1
               hsh 
            }.sort_by{|h| h[1]}.reverse

            return vals.first[0]
         end
      end


    end
    include ExportAsAttributes


#### CLASS METHODS


    def self.parse_twitter_handle(url)
       if handle = url.strip.match(TWITTER_URL_REGEXES[:twitter_profile])
          return handle[1]
       end
    end

    # returns two dimensional array of url handle and context 
    def self.detect_twitter_accounts(parsed_content)
       arr = []
       # look for official button first
       if button = parsed_content.css('a.twitter-follow-button').first
          if handle = parse_twitter_handle( button['href'] )
             arr << [handle, 'twitter-follow-button'] 
          end
       end

       
       twitter_links = parsed_content.css('a').select{|a| a['href'] =~ TWITTER_URL_REGEXES[:twitter_profile]}

       # look for link text with "follow" or "me"
       _follow_text = TWITTER_URL_REGEXES[:follow_text]
       twitter_links.each do |link|
          if link.text =~ _follow_text || link.parent.andand.text.to_s =~ _follow_text
             arr << [parse_twitter_handle(link['href']), 'link-text-follow']
             twitter_links.delete link # uh this could be bad
          end
       end  
       
       # remaining links are just text links
       twitter_links.each do |link|
          # just plain old link
          arr << [parse_twitter_handle(link['href']), 'link']
       end


       return arr 
    end


  end
end