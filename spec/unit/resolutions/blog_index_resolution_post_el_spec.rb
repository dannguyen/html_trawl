require 'spec_helper'

describe BlogIndexResolver do 

   context "post and link elements counting" do 

      before(:each) do 
         @html = %q{<!doctype html><html lang="en"><head><meta charset="UTF-8" />
        <title>Document</title></head><body>
         <article><div class='hentry'>   
            <h2><a href="http://example.com/link1">Link 1</a></h2>
            <p class="content">Hello this is some content</p>
            <p><a href="http://example.com/link1">Read more...</a></p>
         </div></article>

         <article><div class='hentry'>   
            <h2><a href="http://example.com/link1">Link 2</a></h2>
            <p class="content">Hello this is some content</p>
            <p><a href="http://example.com/link2">Read more...</a></p>
         </div></article>

         <article><div class='hentry'>   
            <h2><a href="http://example.com/link1">Link 3</a></h2>
            <p class="content">Hello this is some content</p>
            <p><a href="http://example.com/link3">Read more...</a></p>
         </div></article>


        </body></html>    
         }

         @resolver = BlogIndexResolver.new(@html)
      end

      describe '#detect_post_element_xpaths' do
         it 'should count post elements based on article elements' do
            xpaths = @resolver.detect_post_element_xpaths
            
            expect( xpaths.first[0] ).to eq '/html/body/article'
            expect( xpaths.first[1] ).to eq 3
         end

         it 'should have #collect_post_elements follow similarly' do 
            els = @resolver.collect_post_elements
            expect( els.first.path).to match '/html/body/article'
            expect(els.count).to eq 3
         end
      end

      describe '#post_urls' do 
         it 'should have as many post links as posts' do 
            expect(@resolver.post_urls_count ).to eq 3
         end

         it 'should expect each link to be a child of a post element' do 
            url = @resolver.post_urls.first 
            post = @resolver.collect_post_elements.first 

            expect(post.css('a').map{|a| a['href'] }).to include url
         end
      end


   end
end
