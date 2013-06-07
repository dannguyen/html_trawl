require 'spec_helper'

describe "Trawler for Social Accounts" do 
include Trawler::SocialAccounts


   describe "Twitter finder" do 
      it "should locate twitter accounts" do 
         @page = PageFixtures.load('posts/danwin-mid.html')
         detect_twitter_accounts(@page).andand.first.must_equal ['dancow', 'twitter-follow-button']
      end

      it "should NOT pick up twitter.com/share" do 
         bad_content = %Q{<html><body><a href="http://twitter.com/share" class="twitter-follow-button"></a></body></html>}
         detect_twitter_accounts(bad_content).must_be_empty
      end

      describe "priority finding" do 
         before do 
            @content = %Q{

            <!doctype html><html lang="en"><head><meta charset="UTF-8" /><title>Document</title></head><body>

<p>This is not  <a href="http://twitter.com/reallynotdancow">the target</a></p>

<p>So he said <a href="http://twitter.com/notdancow">Yo in this tweet profile</a></p>
<p>Follow me <a href="http://twitter.com/dancow">at @dancow</a></p>
<a
href="http://twitter.com/dancow"  class='twitter-follow-button' data-show-count='false'>Follow @dancow</a>

            </body></html>         }

         end

         it "should locate a mix of accounts" do 
            resp = detect_twitter_accounts(@content)

            resp[0].must_equal ['dancow', 'twitter-follow-button']
            resp[1].must_equal ['dancow', 'link-text-follow']
            resp[2].must_equal ['reallynotdancow', 'link']
            resp[3].must_equal ['notdancow', 'link']
         end

         it "should pick most likely choice " do 
            pick_twitter_account(@content).must_equal 'dancow'
         end

         it "should make a sophie's choice when not obvious" do 
            mixed_content = %Q{

            <!doctype html><html lang="en"><head><meta charset="UTF-8" /><title>Document</title></head><body>

<p>This is not  <a href="http://twitter.com/reallynotdancow">the target</a></p>
<p>This might be  <a href="http://twitter.com/dancow">the target</a></p>
<p>This could be  <a href="http://twitter.com/dancow">the target</a></p>
<p>This is not  <a href="http://twitter.com/sonotdan">the target</a></p>

            </body></html>         }

            pick_twitter_account(mixed_content).must_equal 'dancow'

         end

      end
   end   



end

