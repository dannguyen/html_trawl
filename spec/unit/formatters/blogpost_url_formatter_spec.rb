require 'spec_helper'

describe 'BlogUrlFormatter' do 
   context 'instances' do 
      describe '#matches?' do 
         it 'should capture basic dates' do 
            @url_format = BlogUrlFormatter.new(path: '/:year/:month/:slug')
            expect(@url_format.matches?('http://example.com/2006/12/my-first-post')).to be_true
            expect(@url_format.matches?('http://example.com/somecategory/my-first-post')).to be_false
         end

         it 'should capture just a slug' do 
            @url_format = BlogUrlFormatter.new(path: '/:slug')
            expect(@url_format.matches?('http://example.com/a-slug')).to be_true
            expect(@url_format.matches?('http://example.com/2009-rules')).to be_true
            expect(@url_format.matches?('http://example.com/2009/slug')).to be_false
         end



         it 'should handle file format extensions'

         it 'allow for an optional host name' do 
            @url_format = BlogUrlFormatter.new(path: '/:slug', host: 'http://www.example-blog.com')
            expect(@url_format.host).to eq 'example-blog.com'
            expect(@url_format.matches?('http://example-blog.com/my-post')).to be_true
            expect(@url_format.matches?('http://example-baddd.com/my-post')).to be_false
            expect(@url_format.matches?('http://blog.example-blog.com/my-post')).to be_false
         end
     
         it 'allow for hard coded subdirectories' do 
            @url_format = BlogUrlFormatter.new(path: 'articles/:slug')
            expect(@url_format.matches?('http://blog.com/articles/my-post')).to be_true
            expect(@url_format.matches?('http://blog.com/article/my-post')).to be_false
         end


         it 'should handle queries' do 
            @url_format = BlogUrlFormatter.new(query_params: ['q'])
            expect(@url_format.matches?('http://example.com/?q=42')).to be_true
            expect(@url_format.matches?('http://example.com/index/?q=42')).to be_false
            # query params must be explicitly stated
            expect(@url_format.matches?('http://example.com/?q=42&date=2019')).to be_false
         end

      end
   end


   describe '::factory', skip: true do 
      it 'should handle url with sitename, year, month, day' do 

         @url_format = BlogUrlFormatter.factory "http://example.com/2012/06/12/a-post-name"
         expect(@url_format.domain).to eq 'example.com'
         expect(@url_format.path_format).to eq ':year/:month/:day/:slug'
      end
   end

end