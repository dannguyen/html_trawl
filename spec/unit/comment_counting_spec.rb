require 'spec_helper'

describe "CommentSection analysis" do 

   describe "comment_count" do 

      it "should return nil if no comment section found" do 
         skip
         @html = "<html></html>"
         PageAnalyzer.new(@html).comment_count.must_be_nil 
      end

      it "should as a last resort look for a comments section and then a headline tag" do 

         skip 
%q{<div id="comments">
      <h3 class="cufon">70 Responses to "What The Rails Security Issue Means For Your Startup"</h3>
</div>}

      end 

      it "should use .comments-title to find existence of Wordpress comments" do 
         skip
         @html = %q{<h2 class="comments-title"> 2 thoughts on "<span>Flickr's redesign makes it a photo service actually worth sharing</span>"</h2>}
         pa = PageAnalyzer.new @html         
         pa.comment_count.must_equal 2
      end

      it "should use .comments_title/.commentstitle as indicator of comments also" do 
         skip
         @html = %q{<h2 class="comments_title"> 2 thoughts on  "<span>Flickr's redesign makes it a photo service actually worth sharing</span>"</h2>}
         pa = PageAnalyzer.new @html         
         pa.comment_count.must_equal 2

         @html = %q{<h2 class="commentstitle"> 2 thoughts on  "<span>Flickr's redesign makes it a photo service actually worth sharing</span>"</h2>}
         pa = PageAnalyzer.new @html         
         pa.comment_count.must_equal 2

      end

      it "should count comments from title with irregular start of sentence" do 
         skip
         @html = %q{<h2 class="commentstitle"> There are 2 comments on  "<span>Flickr's redesign makes it a photo service actually worth sharing</span>"</h2>}
         pa = PageAnalyzer.new @html         
         pa.comment_count.must_equal 2
      end
   end

end