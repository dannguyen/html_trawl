require 'spec_helper'


describe FacebookResolver do 

	context "Facebook widget methods" do 
		describe '#facebook_accounts' do 

			it "should locate basic facebook link" do 
				@resolver = FacebookResolver.new(%q{<html><a href="http://www.facebook.com/example"><img src="http://www.example.com/wp-content/themes/example/images/Facebook.png" alt="Facebook"></a></html>})
				expect(@resolver.facebook_accounts).to eq [["example", :href]]
			end
	
			it "should locate locate two basic facebook link" do 
				@resolver = FacebookResolver.new(%q{<html><a href="http://www.facebook.com/example"><img src="http://www.example.com/wp-content/themes/example/images/Facebook.png" alt="Facebook"></a>
					stuff stuff
					<a href="https://facebook.com/example">FB again</a>
					</html>})
	
				expect(@resolver.facebook_accounts).to eq [["example", :href], ["example", :href]]
			end


		end

		describe '#likely_facebook_account' do 
			it "should choose most likely FB" do 
				@resolver = FacebookResolver.new(%q{<html><a href="http://www.facebook.com/example"><img src="http://www.example.com/wp-content/themes/example/images/Facebook.png" alt="Facebook"></a>
					stuff stuff
					<a href="https://facebook.com/example">FB again</a>
					</html>})
	
				expect(@resolver.likely_facebook_account).to eq "example"
			end

			it "should return nil if no FB accounts" do 
				expect( FacebookResolver.new("<html></html>").likely_facebook_account).to be_nil	
			end
		end
	end

end