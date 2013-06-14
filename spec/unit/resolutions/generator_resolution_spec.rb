require 'spec_helper'
describe "Should detect the content generator", skip: false do 


   describe '#likely_cms' do 
      context "WordPress" do 
         it "should detect obvious Wordpress site" do
            @resolver = GeneratorResolver.new PageFixtures.load('posts/danwin-mid.html')
            expect( @resolver.likely_cms ).to eq 'WordPress'
         end

      end
   end

   context "Blogger" do 
   end


   context "Drupal" do 
   end


   context "Tumblr" do 
   end


end