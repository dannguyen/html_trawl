require 'spec_helper'
describe "Should detect the content generator", skip: false do 


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

   end

   context "Blogger" do 
   end


   context "Drupal" do 
   end




end