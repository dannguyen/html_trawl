require 'spec_helper'
describe "Should detect the content generator", skip: false do 

   describe '#exported_hash' do 

      it 'should return Mash with :likely_cms and :cms_candidates' do 
         @resolver = GeneratorResolver.new PageFixtures.load('posts/danwin-mid.html')
         @hsh = @resolver.to_hash
         expect( @hsh.likely_cms ).to eq 'WordPress'
         expect( @hsh.cms_candidates ).to be_a Hash
      end
   end
   describe '#likely_cms' do 
      context "WordPress" do 
         it "should detect obvious Wordpress site" do
            @resolver = GeneratorResolver.new PageFixtures.load('posts/danwin-mid.html')
            expect( @resolver.likely_cms ).to eq 'WordPress'
         end
      end
 
      context "Tumblr" do 
         it "should detect obvious Tumblr site" do 
            @resolver = GeneratorResolver.new PageFixtures.load('pages/tumblr-page-2.html')
            expect( @resolver.likely_cms ).to eq 'Tumblr'
         end      
      end

      context "Blogger" do 
         it 'should detect obvious Blogger site' do 
            @resolver = GeneratorResolver.new PageFixtures.load('posts/google.blogspot.post.html')
            expect( @resolver.likely_cms ).to eq 'Blogger'
         end
      end

      context "Drupal" do 
         it "should detect obvious Drupal site" do 
            @resolver = GeneratorResolver.new PageFixtures.load('posts/whitehouse.blogpost.html')
            expect( @resolver.likely_cms ).to eq 'Drupal'
         end
      end

   end




end