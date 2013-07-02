require 'spec_helper'

describe "WordPressIndexResolver", skip: false do

   describe "actual index page, post elements detection" do

      context 'elliott blog' do 
         before(:each) do 
             @resolver = WordPressIndexResolver.new( PageFixtures.load('pages/wp-elliott-index.html'))
         end

         it 'should return post elements' do  
            expect( @resolver.collect_post_elements.count ).to eq 7
         end

         it 'should have headline elements for each post element' do 
            expect( @resolver.post_urls_count).to eq 7
         end
      end 

      context 'google blogspot (yes, this is not wordpress)' do 
         before(:each) do 
             @resolver = WordPressIndexResolver.new( PageFixtures.load('pages/google-blogspot-index.html'))
         end

         it 'should return post elements' do  
            expect( @resolver.collect_post_elements.count ).to eq 10
         end

         it 'should have headline elements for each post element' do 
            expect( @resolver.post_urls_count).to eq 10
         end
      end


   end
end