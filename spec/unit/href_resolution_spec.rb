require 'spec_helper'

 describe "affix to relative url" do 

      before do 
         @url = "http://example.com"
         @html = %q{
            <!DOCTYPE html><html>
               <body>
               <p>Text and <a href="/here">first link</a></p>
               <p>Absolute <a href="http://www.skift.com">second link</a></p>     
               <p>Internal page anchor <a href="#nowhere">third link</a> </p>      
               <p>Unparseable link <a href="this is not a link">unpareseable fourth link</a> </p>      

              </body>
            </html>
         }

         @analyzer = PageAnalyzer.new @html, url: @url
      end


      it "should accept url as optional parameter" do 
         @analyzer.url.must_equal @url
      end

      describe "when url is provided" do 
         it "should convert relative link to absolute link" do 
            link = @analyzer.parsed_html.css('a')[0]
            link['href'].must_equal URI.join(@url, '/here').to_s
         end


         it "should not convert absolute link" do 
            link = @analyzer.parsed_html.css('a')[1]
            link['href'].must_equal 'http://www.skift.com'
         end

         it "should not convert internal page anchor link" do 
         # this test is dumb - Dan

#            link = @analyzer.parsed_html.css('a')[2]
#            link['href'].must_equal '#nowhere'
         end


         it "should convert unparseable links to nil" do 
            @analyzer.parsed_html.css('a')[3]['href'].must_be_empty
         end


      end



      describe "when url is NOT provided" do 
         it "should not convert relative link to absolute link" do 
            @a = PageAnalyzer.new @html 
            @a.parsed_html.css('a')[0]['href'].must_equal '/here'
         end
      end


   end
