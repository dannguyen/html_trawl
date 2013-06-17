require 'spec_helper'

describe ArticleResolver do

 context "content analysis"  do 
      before do 
         @simple_content = "<section id='main'><div><p>Hello world!</p><p>The quick brown fox jumps over the dog -- so it goes.</p></div></section>"
         @simple_html = %Q{
            <!doctype html><html lang="en"><head><meta charset="UTF-8" /><title>Document</title></head><body>#{@simple_content}<aside>
            Do not pick this up</aside>
            </body></html>
         }

         @resolver =  ArticleResolver.new @simple_html
      end

      it "should extract main article into content" do 
         #  ugly gsubs are needed because
         #  Sanitize.clean converts block tags to newlines
         expect( Sanitize.clean(@resolver.content).gsub(/\s+/, ' ').strip).to eq "Hello world! The quick brown fox jumps over the dog -- so it goes."
         expect( @resolver.content_text.gsub(/\s+/, ' ')).to eq Sanitize.clean(@simple_content).gsub(/\s+/, ' ').strip 
      end


      it "should count number of words" do 
         expect( @resolver.content_words).to eq %w(Hello world The quick brown fox jumps over the dog so it goes)
         expect( @resolver.content_word_count).to eq 13
      end

   end


   describe "exporting to_hash" do 

      it "should export to_hash" do 
         @blog_post ||= PageFixtures.load('posts/danwin-mid.html')
         @resolver =  ArticleResolver.new @blog_post
         hsh = @resolver.to_hash 
         expect(hsh.content_title).to eq 'The Google death and resurrection of Amy Wilentz'
      end
   end


   describe "meta analysis via pismo" do 

      before do 
         @blog_post ||= PageFixtures.load('posts/danwin-mid.html')
         @resolver =  ArticleResolver.new @blog_post
      end


      it "should have published_timestamp" do 
         expect( @resolver.content_published_timestamp.strftime("%Y-%m-%d")).to eq '2013-03-22'
      end

      it "should have title based off of headline" do 
         expect( @resolver.content_title).to eq 'The Google death and resurrection of Amy Wilentz'
      end

   end
end


