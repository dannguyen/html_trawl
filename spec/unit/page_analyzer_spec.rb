require 'spec_helper'


describe "PageAnalyzer" do 

  
  

   describe "node analysis" do 

      before do 

         @img_data = PageFixtures.load('images/example-600x400.gif')
         FakeWeb.register_uri(:get, "http://example.com/some.gif" , 
               body: @img_data
            )


         @node_content = %q{<section id='main'>
         <div><p>Hello world!</p><p>The quick brown fox <a href="http://example.com">jumps</a> over the dog -- so it <a href="http://google.com">goes</a>.</p>
<p><a href="/goes/to/path"><img src="http://example.com/some.gif"></a></p>
         </div></section>}
         
         @node_html = %Q{
            <!doctype html><html lang="en"><head><meta charset="UTF-8" /><title>Document</title></head><body>#{@node_content}<aside>
            Do not pick this up</aside>
            </body></html>
         }

         @analyzer =  PageAnalyzer.new @node_html
      end

      it "should count number of links" do
         @analyzer.content_links.count.must_equal 3
         @analyzer.content_links[0]['href'].must_equal 'http://example.com'

      end


      it "should get number of image_nodes" do 
         @analyzer.content_image_nodes.count.must_equal 1
         @analyzer.content_image_nodes.first.must_equal 'http://example.com/some.gif'
      end

   end





end 