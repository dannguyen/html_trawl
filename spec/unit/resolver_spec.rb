require 'spec_helper'

class MyResolver < HtmlTrawl::Resolver 
   module ExportAsAttributes
      def foo1
         "baz1"
      end

      def foo2
         "baz2"
      end
   end
   include ExportAsAttributes
end


describe HtmlTrawl::Resolver, skip: false do
	before(:each) do 
		@resolver = MyResolver.new("<html></html>")
	end
	it "should have @parsed_html accessor as a Nokogiri node" do 
		expect( @resolver.parsed_html ).to be_kind_of Nokogiri::XML::Node
	end

   context "exporting methods" do 
      it 'should have accessible list of exported methods' do 
         expect(@resolver.exportable_attributes).to eq [:foo1, :foo2]
      end
      it "should export the methods via a Hashie" do 
         hsh = @resolver.to_hash
         expect(hsh.values).to include 'baz1', 'baz2'
      end
   end
end 
