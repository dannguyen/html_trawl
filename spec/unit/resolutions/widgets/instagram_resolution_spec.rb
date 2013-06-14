require 'spec_helper'


describe InstagramResolver do 

  context "Instagram widget methods" do 
    describe '#instagram_accounts' do 

      it "should locate basic Instagram link" do 
        @resolver = InstagramResolver.new(%q{<html><a href="http://www.instagram.com/example"><img src="http://www.example.com/wp-content/themes/example/images/Instagram.png" alt="Instagram"></a></html>})
        expect(@resolver.instagram_accounts).to eq [["example", :href]]
      end
  
      it "should locate locate two basic Instagram link" do 
        @resolver = InstagramResolver.new(%q{<html><a href="http://www.instagram.com/example"><img src="http://www.example.com/wp-content/themes/example/images/Instagram.png" alt="Instagram"></a>
          stuff stuff
          <a href="https://instagram.com/example">Instagram again</a>
          </html>})
  
        expect(@resolver.instagram_accounts).to eq [["example", :href], ["example", :href]]
      end


    end

    describe '#pick_instagram_account' do 
      it "should choose most likely FB" do 
        @resolver = InstagramResolver.new(%q{<html><a href="http://www.instagram.com/example"><img src="http://www.example.com/wp-content/themes/example/images/Instagram.png" alt="Instagram"></a>
          stuff stuff
          <a href="https://instagram.com/example">Instagram again</a>
          </html>})
  
        expect(@resolver.pick_instagram_account).to eq "example"
      end

      it "should return nil if no Instagram accounts" do 
        expect( InstagramResolver.new("<html></html>").pick_instagram_account).to be_nil  
      end
    end
  end

end