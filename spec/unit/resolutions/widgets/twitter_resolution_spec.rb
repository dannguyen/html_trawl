require 'spec_helper'

describe WidgetResolver do 


   context "Twitter" do 

 
      describe '#twitter_accounts' do 
         it "should locate twitter accounts" do 
            @resolver = WidgetResolver.new PageFixtures.load('posts/danwin-mid.html')
            expect( @resolver.twitter_accounts.first).to eq ['dancow', 'twitter-follow-button']
         end
      end

      describe '#pick_twitter_account' do 
       
         it "should NOT pick up twitter.com/share" do 
            bad_content = %Q{<html><body><a href="http://twitter.com/share" class="twitter-follow-button"></a></body></html>}
            @resolver = WidgetResolver.new bad_content 
            expect( @resolver.twitter_accounts ).to be_empty
         end

         it "should return nil if no choice" do 
            @resolver = WidgetResolver.new(%Q{<html></html>})
            expect(@resolver.pick_twitter_account).to be_nil
         end



         context "priority finding" do 
            before do 
               @content = %Q{

               <!doctype html><html lang="en"><head><meta charset="UTF-8" /><title>Document</title></head><body>

   <p>This is not  <a href="http://twitter.com/reallynotdancow">the target</a></p>

   <p>So he said <a href="http://twitter.com/notdancow">Yo in this tweet profile</a></p>
   <p>Follow me <a href="http://twitter.com/dancow">at @dancow</a></p>
   <a
   href="http://twitter.com/dancow"  class='twitter-follow-button' data-show-count='false'>Follow @dancow</a>

               </body></html>         }

               @resolver = WidgetResolver.new @content 
            end

            it "should locate a mix of accounts" do 
               arr = @resolver.twitter_accounts 

               expect( arr[0]).to eq ['dancow', 'twitter-follow-button']
               expect( arr[1]).to eq ['dancow', 'link-text-follow']
               expect( arr[2]).to eq ['reallynotdancow', 'link']
               expect( arr[3]).to eq ['notdancow', 'link']
            end

            it "should pick most likely choice " do 
               expect( @resolver.pick_twitter_account ).to eq 'dancow'
            end



            it "should make a sophie's choice when not obvious" do 
               mixed_content = %Q{

               <!doctype html><html lang="en"><head><meta charset="UTF-8" /><title>Document</title></head><body>

   <p>This is not  <a href="http://twitter.com/reallynotdancow">the target</a></p>
   <p>This might be  <a href="http://twitter.com/dancow">the target</a></p>
   <p>This could be  <a href="http://twitter.com/dancow">the target</a></p>
   <p>This is not  <a href="http://twitter.com/sonotdan">the target</a></p>

               </body></html>         }

               @resolver = WidgetResolver.new(mixed_content)

               expect( @resolver.pick_twitter_account  ).to eq 'dancow'

            end

         end
      end   

   end

end
