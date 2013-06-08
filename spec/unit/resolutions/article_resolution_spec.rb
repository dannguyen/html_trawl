require 'spec_helper'

 describe "content analysis", skip: true do 
      before do 
         @simple_content = "<section id='main'><div><p>Hello world!</p><p>The quick brown fox jumps over the dog -- so it goes.</p></div></section>"
         @simple_html = %Q{
            <!doctype html><html lang="en"><head><meta charset="UTF-8" /><title>Document</title></head><body>#{@simple_content}<aside>
            Do not pick this up</aside>
            </body></html>
         }

         @analyzer =  PageAnalyzer.new @simple_html
      end

      it "should extract main article into content" do 
         #  ugly gsubs are needed because
         #  Sanitize.clean converts block tags to newlines
         Sanitize.clean(@analyzer.content).gsub(/\s+/, ' ').strip.must_equal "Hello world! The quick brown fox jumps over the dog -- so it goes."
         @analyzer.content_text.gsub(/\s+/, ' ').must_equal Sanitize.clean(@simple_content).gsub(/\s+/, ' ').strip 
      end


      it "should count number of words" do 
         @analyzer.content_words.must_equal %w(Hello world The quick brown fox jumps over the dog so it goes)
         @analyzer.content_word_count.must_equal 13
      end

   end


   describe "meta analysis via pismo" do 

      before do 
         @blog_post ||= PageFixtures.load('posts/danwin-mid.html')
         @analyzer =  PageAnalyzer.new @blog_post
      end


      it "should have published_timestamp" do 
         @analyzer.content_published_timestamp.strftime("%Y-%m-%d").must_equal '2013-03-22'
      end

      it "should have title based off of headline" do 
         @analyzer.content_title.must_equal 'The Google death and resurrection of Amy Wilentz'
      end

   end

