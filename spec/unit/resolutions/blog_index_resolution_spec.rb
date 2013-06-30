require 'spec_helper'

describe BlogIndexResolver, skip: false do

   describe "post headline detection" do

      it 'should #post_elements_count based on headline links found in likely post elements' do 
         @resolver = BlogIndexResolver.new(%q{
            <html><head></head>
<body>
<div class="hentry"><h2><a href="http://example.com/1">Some article</a></h2></div>
<div class="hentry"><h2><a href="http://example.com/2">Some article</a></h2></div>
<div class="hentry"><h2><a href="http://example.com/3">Some article</a></h2></div>
<div class="hentry"><h2><a href="http://example.com/4">Some article</a></h2></div>
<div class="hentry"><h2><a href="http://example.com/5">Some article</a></h2></div>
</body>
</html>}
)

         expect( @resolver.post_urls_count ).to eq 5
      end

      it 'should return 0 when no elements are found' do 
         @resolver = BlogIndexResolver.new(%q{<html><body></body></html>})
         expect( @resolver.post_urls_count ).to eq 0
      end

      it 'should return 0 if no links wrapped in headline are found' do 
         @resolver = BlogIndexResolver.new(%q{<html><body>
            <p><a href="http://example.com/stuff">Example</a></p>
         </body></html>})
         expect( @resolver.post_urls_count ).to eq 0
      end

     
   end


   describe ':headline_element', skip: true do
   ### DEPRECATED: leave headline minimum count to calling methods
    
      it 'should NOT count headline occurrences of less than MINIMUM_HEADLINE_ELEMENT_COUNT' do 
         @resolver = BlogIndexResolver.new(%q{<html><body>
            <div class="hentry"><h4><a href="http://example.com/stuff">Example</a></h4></div>
         </body></html>})

         expect( @resolver.headline_element ).to be_nil
      end

      it 'should count headline occurrences of more than MINIMUM_HEADLINE_ELEMENT_COUNT' do 
         @resolver = BlogIndexResolver.new(%q{<html><body>
            <div class="hentry"><h4><a href="http://example.com/stuff">Example</a></h4></div>
            <div class="hentry"><h4><a href="http://example.com/stuff2">Example2</a></h4></div>
            <div class="hentry"><h4><a href="http://example.com/stuff3">Example3</a></h4></div>
            <div class="hentry"><h4><a href="http://example.com/stuff4">Example4</a></h4></div>
         </body></html>})

         expect( @resolver.headline_element ).to eq 'div > h4 > a'
      end
   end

end