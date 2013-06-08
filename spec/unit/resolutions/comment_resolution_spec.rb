require 'spec_helper'

describe "CommentSection analysis", skip: true do 
# include HtmlTrawl::Resolver::Commenting

   describe "detect_comments_heading" do 

      it "should return nil if no comment section found" do 
         @html = "<html></html>"
         expect( detect_comments_heading @html ).to be_nil 
      end

      it "should as a last resort look for a comments section and then a headline tag" do 
         @html = %q{<div id="comments">
      <h3 class="cufon">70 Responses to "What The Rails Security Issue Means For Your Startup"</h3>
</div>}

         expect( detect_comments_heading @html ).to eq %q{<h3 class="cufon">70 Responses to "What The Rails Security Issue Means For Your Startup"</h3>}
      end 


      context "wordpress" do 
         it "should use .comments-title to find existence of Wordpress comments" do                   
            @html = %q{<h2 class="comments-title"> 2 thoughts on "<span>Flickr's redesign makes it a photo service actually worth sharing</span>"</h2>}
            expect( detect_comments_heading @html ).to eq @html
            expect( detect_comments_count @html).to eq 2
         end

         it "should use .comments_title/.commentstitle as indicator of comments also" do 
            @html = %q{<h2 class="comments_title"> 5 thoughts on  "<span>Flickr's redesign makes it a photo service actually worth sharing</span>"</h2>}
            expect( detect_comments_count ).to eq 5


            @html_2 = %q{<h2 class="commentstitle"> 2 thoughts on  "<span>Flickr's redesign makes it a photo service actually worth sharing</span>"</h2>}
            expect( detect_comments_count @html_2).to eq 2

         end

         it "should count comments from title with irregular start of sentence" do 
            @html = %q{<h2 class="commentstitle"> There are 2 comments on  "<span>Flickr's redesign makes it a photo service actually worth sharing</span>"</h2>}
            expect( detect_comments_count @html).to eq 2
         end
      end

   end
end