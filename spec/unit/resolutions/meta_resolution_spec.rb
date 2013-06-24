require 'spec_helper'

describe MetaResolver do

 context "head analysis"  do 
      before do 
         @simple_html = %Q{
<!doctype html><html lang="en"><head><meta charset="UTF-8" />
   <head>
   <title>Document</title>
   <meta name="keywords" content="NYC,Example" />
      <meta name="description" content="Metadoc" />
<link rel="canonical" href="http://example.com/canonical" />

<!-- ogg stuff -->

<meta property='og:title' content='Og Title'/>
<meta property='og:description' content='This is og description'/>
<meta property='og:image' content='http://example.com/image.png'/>



            </head><body>
            <section>
            Do not pick this up</section>
            </body></html>
         }

         @resolver =  MetaResolver.new @simple_html
      end

      context "standard meta tags" do 
         it 'should extract #meta_title' do 
            expect(@resolver.meta_title ).to eq 'Document'
         end

         it 'should extract #meta_description' do 
            expect(@resolver.meta_description ).to eq 'Metadoc'
         end

         it 'should extract #meta_keywords as String' do 
            expect(@resolver.meta_keywords).to eq 'NYC,Example'
         end

         it 'should extract #meta_keywords_array as Array' do 
            expect(@resolver.meta_keywords_array).to include 'NYC','Example'
         end
      end

      context "og meta tags" do 
         it 'should extract #og_title' do 
            expect(@resolver.og_title ).to eq 'Og Title'
         end

         it 'should extract #og_description' do 
            expect(@resolver.og_description ).to eq 'This is og description'
         end

         it 'should extract #og_image as String' do 
            expect(@resolver.og_image).to eq 'http://example.com/image.png'
         end
      end


      context "default values; og vs standard meta" do 
         it "should prefer og values" do 
            expect(@resolver.title).to eq @resolver.og_title
         end

         it "should default to standard meta if og not present" do 
            expect(@resolver.keywords).to eq @resolver.meta_keywords
         end         
      end


      describe "to_hash output" do 
         it 'should export title, description, keywords, image, etc' do 
           expect( @resolver.to_hash.keys ).to include('title', 'description', 'keywords', 'image')
         end
      end


   end
end


