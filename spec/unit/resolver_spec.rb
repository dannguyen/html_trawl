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


   describe '#main_content' do 
      before(:each) do 
         @resolver = MyResolver.new(%q{<html><head>
         <title>Doc</title>
         </head>
         <body>
         <div id="sidebar">
            Sidebar content
            <div class="widget">Widgety</div>
         </div>
         <article>
               <h1>Article Headline</h1>
               <p>text</p>
         </article>
         </body>
         </html>})

         @main_content = @resolver.main_content
      end

      it 'should not include the #sidebar content' do 
         expect( @main_content.text ).to_not match /Sidebar content/ 
      end

      it 'should not include the .widget content' do 
         expect( @main_content.text ).to_not match /Widgety/
      end

      it 'should still include regular content' do 
         expect(@main_content.text ).to match /Article Headline/
      end


   end
end 
