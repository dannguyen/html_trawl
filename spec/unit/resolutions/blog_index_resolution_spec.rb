require 'spec_helper'

describe BlogIndexResolver, skip: false do

   describe "post headline detection" do

      it 'should #post_elements_count based on headline links found in likely post elements' do 
         @resolver = BlogIndexResolver.new(%q{
            <html><head></head>
<body>
<div class="post"><h2><a href="http://example.com/1">Some article</a></h2></div>
<div class="post"><h2><a href="http://example.com/2">Some article</a></h2></div>
<div class="post"><h2><a href="http://example.com/3">Some article</a></h2></div>
<div class="post"><h2><a href="http://example.com/4">Some article</a></h2></div>
<div class="post"><h2><a href="http://example.com/5">Some article</a></h2></div>
</body>
</html>}
)

         expect( @resolver.post_links_count ).to eq 5
      end

      it 'should return 0 when no elements are found' do 
         @resolver = BlogIndexResolver.new(%q{<html><body></body></html>})
         expect( @resolver.post_links_count ).to eq 0
      end

      it 'should return 0 if no headline links found' do 
         @resolver = BlogIndexResolver.new(%q{<html><body>
            <p><a href="http://example.com/stuff">Example</a></p>
         </body></html>})
         expect( @resolver.post_links_count ).to eq 0
      end
   end
end