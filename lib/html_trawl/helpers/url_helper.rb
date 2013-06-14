require 'uri'
module HtmlTrawl
   module Helpers
      module URL 

         # returns string
         # returns nil if InvalidURI for either things
         def normalize_url(org_uri, refu)

            # return nil if org_uri is not a properly parsed URI
            begin 
               uri = org_uri.is_a?(URI) ? org_uri.dup : URI.parse(org_uri) 
            rescue URI::InvalidURIError => e 
               return nil 
            end

            # now, if the referring uri, refu, is blank, 
            ## return org_uri 
            return org_uri if refu.blank?

            # get a URI object from refu
            referer_url = refu.is_a?(URI) ? refu.dup : URI.parse( refu) 

            ## skip if referer_url is not a URL
            return org_uri unless referer_url.is_a?(URI::HTTP)
            
            # already an absolute link
            if uri.is_a?( URI::HTTP ) 
               return uri.to_s 
            end 

            if uri.to_s.empty?
               return referer_url.to_s
            end


            ## "//" web absolute address, return with referer's scheme
            if uri.to_s =~ /^\/\// 
               return uri.tap{|u| u.scheme = referer_url.scheme }.to_s
            end


            return (URI.join referer_url, uri ).to_s
         end


      end
   end
end
