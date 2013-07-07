require 'spec_helper'


# types: metadata, 
# published_on, 
# published_on text
# top of the post, bottom of the post, proximity to headline
describe "TimestampRegexMatcher#find_matches", skip: false do 
   context 'just dates' do
      context 'numeric' do 

         context 'programmatic date formats', focus: true do 
            it 'should find official timestamps in YYYY-MM-DD format' do 
               @str = '2013-07-25 11:41:40 -0400'
               @matches = TimestampRegexMatcher.find_matches(@str)

               expect(@matches.count).to eq 1

               @mtch = @matches.first
               expect(@mtch.regex_name).to eq :programmatic_standard
               expect(@mtch.regex_value).to eq 100
               expect(@mtch[:year]).to eq '2013'
               expect(@mtch[:month]).to eq '07'
               expect(@mtch[:day]).to eq '25'
            end

          
            it 'should find timestamp buried in a string' do 
               @str = %q{<div><span class="datetime">2009-06-12 11:10</span></div>}
               @matches = TimestampRegexMatcher.find_matches(@str)
               @mtch = @matches.first 

               expect(@mtch.regex_name).to eq :programmatic_standard
               expect(@mtch[:year]).to eq '2009'
               expect(@mtch[:month]).to eq '06'
               expect(@mtch[:day]).to eq '12'
            end

            context 'negatories' do 
               it 'should not match invalid month of 13' do 
                  @str = %q{On 2012-13-01}
                  expect(TimestampRegexMatcher.find_matches(@str)).to be_empty
               end

               it 'should not match invalid day of 32' do 
                  @str = %q{On 2012-12-32}
                  expect(TimestampRegexMatcher.find_matches(@str)).to be_empty
               end

               it 'should not match invalid day of 0' do 
                  @str = %q{On 2012-01-00}
                  expect(TimestampRegexMatcher.find_matches(@str)).to be_empty
               end
            end


         end

         context "U.S. date standards" do 
            it 'should detect MM/DD/YYYY' do 
               @str = %q{On 09/03/1975}
               @match = TimestampRegexMatcher.find_matches(@str).first
               expect(@match.regex_name).to eq :us_standard_numeric

               expect(@match.year).to eq '1975'
               expect(@match.month).to eq '09'
               expect(@match.day).to eq '03'
            end

            it 'should detect MM-DD-YYYY' do 
               @str = %q{On 09-03-1975}
               @match = TimestampRegexMatcher.find_matches(@str).first
               expect(@match.year).to eq '1975'
               expect(@match.month).to eq '09'
               expect(@match.day).to eq '03'
               expect(@match.regex_name).to eq :us_standard_numeric
            end

            it 'should detect M-D-YY' do 
               @str = %q{On 9-3-75}
               @match = TimestampRegexMatcher.find_matches(@str).first
               expect(@match.year).to eq '75'
               expect(@match.month).to eq '9'
               expect(@match.day).to eq '3'
               expect(@match.regex_name).to eq :us_standard_numeric
            end

            it 'should detect M-DD-YY' do 
               @str = %q{On 9-31-75}
               @match = TimestampRegexMatcher.find_matches(@str).first
               expect(@match.year).to eq '75'
               expect(@match.month).to eq '9'
               expect(@match.day).to eq '31'
            end

            context 'negatories' do 
               it 'should not match invalid month of 13' do 
                  @str = %q{On 13-31-75}
                  expect(TimestampRegexMatcher.find_matches(@str)).to be_empty
               end

               it 'should not match invalid day of 32' do 
                  @str = %q{On 12-32-75}
                  expect(TimestampRegexMatcher.find_matches(@str)).to be_empty
               end

               it 'should not match invalid day of 0' do 
                  @str = %q{On 12-00-75}
                  expect(TimestampRegexMatcher.find_matches(@str)).to be_empty
               end
            end
         end
      end # numeric dates

      context 'in words' do 

         context 'English' do 
            context 'standard' do 
               it 'should match January 2, 1985' do 
                  @str = 'January 2, 1985'
                  @match = TimestampRegexMatcher.find_matches(@str).first
                  expect(@match.year).to eq '1985'
                  expect(@match.month).to eq 'January'
                  expect(@match.day).to eq '2'
               end

               it 'should match May 12 1985' do 
                  @str = 'May 12 1985'
                  @match = TimestampRegexMatcher.find_matches(@str).first
                  expect(@match.year).to eq '1985'
                  expect(@match.month).to eq 'May'
                  expect(@match.day).to eq '12'
               end

               it 'should match 2-digit abbreviated year: May 12, \'85' do 
                  @str = "May 12, '85"
                  @match = TimestampRegexMatcher.find_matches(@str).first
                  expect(@match.year).to eq "'85"
                  expect(@match.month).to eq 'May'
                  expect(@match.day).to eq '12'
               end

               it 'should match Jan. 7, 1985' do 
                  @str = 'Jan. 7, 1985'
                  @match = TimestampRegexMatcher.find_matches(@str).first
                  expect(@match.year).to eq '1985'
                  expect(@match.month).to eq 'Jan.'
                  expect(@match.day).to eq '7'
               end

               it 'should match Jan. 17, 1985' do 
                  @str = 'Jan. 17, 1985'
                  @match = TimestampRegexMatcher.find_matches(@str).first
                  expect(@match.year).to eq '1985'
                  expect(@match.month).to eq 'Jan.'
                  expect(@match.day).to eq '17'
               end


               

               it 'should match Jan. 17th 1985'
               it 'should match May 1st 1985'
               it 'should match May 3rd, 1985'
            end

            context 'wordy', skip: true do 
               it 'should match January second, 1984'
               it 'should match January Fourth, 1984'
               it 'should match January Fourth, 1984'
            end


            context 'informal' do 
               it 'should match 4th of July, 2012'
               it 'should match Fourth of July, 2012'
               it 'should match Eighteenth of July, 2012'
            end

            context 'negatories' do 
               it 'should not match January 2st 1985'
               it 'should not match October 1th, 1984'
               it 'should not match Feb. 4rd, 2011'
               it 'should not match June 32nd, 1985'
            end

         end

      end

   end # dates



   context 'day and time' do 
      context 'programmatic date formats', skip: true do 
         it 'should find official timestamps in YYYY-MM-DD format' do 
            @str = '2013-07-05 11:41:40 -0400'
            @matches = TimestampRegexMatcher.find_matches(@str)

            expect(@matches.count).to eq 1

            @mtch = @matches.first
            expect(@mtch.regex_name).to eq :programmatic_standard
            expect(@mtch.regex_value).to eq 100
            expect(@mtch.regex_begin).to eq 0
            expect(@mtch.regex_end).to eq @str.length
            expect(@mtch.string_match).to eq @str
            expect(@mtch[:year]).to eq '2013'
            expect(@mtch[:month]).to eq '07'
            expect(@mtch[:day]).to eq '05'
            expect(@mtch[:hour]).to eq '11'
            expect(@mtch[:minute]).to eq '41'
            expect(@mtch[:second]).to eq '40'
            expect(@mtch[:timezone]).to eq '-0400'
         end
      end
   end


   context 'relative times ago', skip: true do 
      it 'should parse Yesterday'
      it 'should parse YESTERDAY'
      it 'should parse YESTERDAY, 3AM'
      it 'should parse five hours ago'
      it 'should parse 5 hours ago'
      it 'should parse 25 MINUTES AGO'
   end


end

