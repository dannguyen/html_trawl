require 'spec_helper'

include HtmlTrawl::Helpers::URL

describe HtmlTrawl::Helpers::URL do 

   describe '#normalize_url' do 
      before do 
         @root = "example.com"
         @referer = "http://#{@root}/"
      end

      it "should return an absolute address" do 
         expect( normalize_url("http://someone.com", @referer)).to eq 'http://someone.com'
      end

      it "should return the referer if blank" do 
         expect( normalize_url("", @referer)).to eq @referer
      end


      it "should return the referer if '/' " do 
         expect( normalize_url("/", @referer)).to eq @referer
      end


      it "should return the referer host if leads with leading '/'" do 
         expect( normalize_url("/hello", @referer)).to eq "http://example.com/hello"

      end


      it "should reuturn the referer host, path" do           
         expect( normalize_url("hello", @referer)).to eq "http://example.com/hello"
      end


      it "should reuturn the referer host, path, subdir" do 
         expect( normalize_url("hello.htm", "http://example.com/world/")).to eq "http://example.com/world/hello.htm"  
      end


      it "Should return nil if url is non parsable" do 
         expect( normalize_url("Bad URI! Bad!", @referer) ).to be_nil
      end

   end
end

