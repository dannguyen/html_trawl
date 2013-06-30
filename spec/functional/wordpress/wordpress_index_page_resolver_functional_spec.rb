require 'spec_helper'

describe "WordPressIndexResolver", skip: false do

   describe "actual index page, post elements detection" do

      it 'should return post elements' do 
         @resolver = WordPressIndexResolver.new( PageFixtures.load('pages/wp-elliott-index.html'))
         
         expect( @resolver.collect_post_elements.count ).to eq 7
         expect( @resolver.post_links_count).to eq 7
      end

   end
end