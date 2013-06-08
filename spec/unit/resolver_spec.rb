require 'spec_helper'


describe HtmlTrawl::Resolver, skip: false do

	before(:each) do 
		@resolver = HtmlTrawl::Resolver.new("<html></html>")
	end
	it "should have @parsed_html accessor as a Nokogiri node" do 
		expect( @resolver.parsed_html ).to be_kind_of Nokogiri::XML::Node
	end

end 
