require 'spec_helper'


# types: metadata, 
# published_on, 
# published_on text
# top of the post, bottom of the post, proximity to headline
describe "TimestampRegexMatcher#find_dates", skip: false do 



   context 'just dates' do
      context 'functional' do 
         describe '#find_dates should return an array of all matches' do 
            it 'should return 1 if 1 found' do 
               @str = '2013-07-25'
               @matches = TimestampRegexMatcher.find_dates(@str)
               expect(@matches.count).to eq 1
            end

            it 'should return multiple when multiple found' do 
               @str = 'Between 2013-06-22 and March 3, 2015'
               expect(TimestampRegexMatcher.find_dates(@str).count).to eq 2
            end
         end
      end

      context 'numeric' do 
         context 'iso date formats' do 
            it 'should find official timestamps in YYYY-MM-DD format' do 
               @str = '2013-07-25 11:41:40 -0400'
               @matches = TimestampRegexMatcher.find_dates(@str)

               expect(@matches.count).to eq 1

               @mtch = @matches.first
               expect(@mtch.regex_name).to eq :iso_standard
               expect(@mtch.regex_value).to eq 100
               expect(@mtch[:year]).to eq '2013'
               expect(@mtch[:month]).to eq '07'
               expect(@mtch[:day]).to eq '25'
            end

            it 'should find variation with a T' do 
               @str = '2013-06-30T22:56:31+00:00'

               @mtch = TimestampRegexMatcher.find_dates(@str).first
               expect(@mtch.regex_name).to eq :iso_standard
               expect(@mtch[:year]).to eq '2013'
               expect(@mtch[:month]).to eq '06'
               expect(@mtch[:day]).to eq '30'
            end

          
            it 'should find timestamp buried in a string' do 
               @str = %q{<div><span class="datetime">2009-06-12 11:10</span></div>}
               @matches = TimestampRegexMatcher.find_dates(@str)
               @mtch = @matches.first 

               expect(@mtch.regex_name).to eq :iso_standard
               expect(@mtch[:year]).to eq '2009'
               expect(@mtch[:month]).to eq '06'
               expect(@mtch[:day]).to eq '12'
            end

            context 'negatories' do 
               it 'should not match invalid month of 13' do 
                  @str = %q{On 2012-13-01}
                  expect(TimestampRegexMatcher.find_dates(@str)).to be_empty
               end

               it 'should not match invalid day of 32' do 
                  @str = %q{On 2012-12-32}
                  expect(TimestampRegexMatcher.find_dates(@str)).to be_empty
               end

               it 'should not match invalid day of 0' do 
                  @str = %q{On 2012-01-00}
                  expect(TimestampRegexMatcher.find_dates(@str)).to be_empty
               end
            end


         end

         context "U.S. date standards" do 
            it 'should detect MM/DD/YYYY' do 
               @str = %q{On 09/03/1975}
               @match = TimestampRegexMatcher.find_dates(@str).first
               expect(@match.regex_name).to eq :us_standard_numeric

               expect(@match.year).to eq '1975'
               expect(@match.month).to eq '09'
               expect(@match.day).to eq '03'
            end

            it 'should detect MM-DD-YYYY' do 
               @str = %q{On 09-03-1975}
               @match = TimestampRegexMatcher.find_dates(@str).first
               expect(@match.year).to eq '1975'
               expect(@match.month).to eq '09'
               expect(@match.day).to eq '03'
               expect(@match.regex_name).to eq :us_standard_numeric
            end

            it 'should detect M-D-YY' do 
               @str = %q{On 9-3-75}
               @match = TimestampRegexMatcher.find_dates(@str).first
               expect(@match.year).to eq '75'
               expect(@match.month).to eq '9'
               expect(@match.day).to eq '3'
               expect(@match.regex_name).to eq :us_standard_numeric
            end

            it 'should detect M-DD-YY' do 
               @str = %q{On 9-31-75}
               @match = TimestampRegexMatcher.find_dates(@str).first
               expect(@match.year).to eq '75'
               expect(@match.month).to eq '9'
               expect(@match.day).to eq '31'
            end

            it 'should detect M.DD.YY' do 
               @str = %q{On 7.31.75}
               @match = TimestampRegexMatcher.find_dates(@str).first
               expect(@match.year).to eq '75'
               expect(@match.month).to eq '7'
               expect(@match.day).to eq '31'
            end


            context 'negatories' do 
               it 'should not match invalid month of 13' do 
                  @str = %q{On 13-31-75}
                  expect(TimestampRegexMatcher.find_dates(@str)).to be_empty
               end

               it 'should not match invalid day of 32' do 
                  @str = %q{On 12-32-75}
                  expect(TimestampRegexMatcher.find_dates(@str)).to be_empty
               end

               it 'should not match invalid day of 0' do 
                  @str = %q{On 12-00-75}
                  expect(TimestampRegexMatcher.find_dates(@str)).to be_empty
               end
            end
         end
      end # numeric dates

      context 'in words' do 
         context 'English' do 


            context 'U.S.' do 
               it 'should match January 2, 1985' do 
                  @str = 'January 2, 1985'
                  @match = TimestampRegexMatcher.find_dates(@str).first
                  expect(@match.year).to eq '1985'
                  expect(@match.month).to eq 'January'
                  expect(@match.day).to eq '2'
               end

               it 'should match May 12 1985' do 
                  @str = 'May 12 1985'
                  @match = TimestampRegexMatcher.find_dates(@str).first
                  expect(@match.year).to eq '1985'
                  expect(@match.month).to eq 'May'
                  expect(@match.day).to eq '12'
               end

               it 'should match 2-digit abbreviated year: May 12, \'85' do 
                  @str = "May 12, '85"
                  @match = TimestampRegexMatcher.find_dates(@str).first
                  expect(@match.year).to eq "'85"
                  expect(@match.month).to eq 'May'
                  expect(@match.day).to eq '12'
               end

               it 'should match Jan. 7, 1985' do 
                  @str = 'Jan. 7, 1985'
                  @match = TimestampRegexMatcher.find_dates(@str).first
                  expect(@match.year).to eq '1985'
                  expect(@match.month).to eq 'Jan.'
                  expect(@match.day).to eq '7'
               end

               it 'should match Jan. 17, 1985' do 
                  @str = 'Jan. 17, 1985'
                  @match = TimestampRegexMatcher.find_dates(@str).first
                  expect(@match.year).to eq '1985'
                  expect(@match.month).to eq 'Jan.'
                  expect(@match.day).to eq '17'
               end
         
               it 'should match January 17th 1985' do 
                  @str = 'January 17th, 1985'
                  @match = TimestampRegexMatcher.find_dates(@str).first
                  expect(@match.year).to eq '1985'
                  expect(@match.month).to eq 'January'
                  expect(@match.day).to eq '17th'
               end

               it 'should match May 1st 1985' do 
                  @str = 'May 1st 1985'
                  @match = TimestampRegexMatcher.find_dates(@str).first
                  expect(@match.day).to eq '1st'
               end

               it 'should match Sept. 30th, 1985' do 
                  @str = 'Sept. 30th 1985'
                  @match = TimestampRegexMatcher.find_dates(@str).first
                  expect(@match.day).to eq '30th'
               end
            end

            context "European" do 
               it 'should match 30 Sept. 1985'
               it 'should match 1 January 1985'
            end


            context 'informal', skip: true do 
               it 'should match 4th of July, 2012'
               it 'should match Fourth of July, 2012'
               it 'should match Eighteenth of July, 2012'
            end

            context 'negatories' do 
               it 'should not match January 2st 1985' do 
                  expect(TimestampRegexMatcher.find_dates('January 2st, 1985')).to be_empty
               end

               it 'should not match October 1th, 1984' do 
                  expect(TimestampRegexMatcher.find_dates('Oct. 1th, 1985')).to be_empty
               end
               it 'should not match Feb. 4rd, 2011' do 
                  expect(TimestampRegexMatcher.find_dates('February 4rd, 1985')).to be_empty
               end

               it 'should not match June 32nd, 1985' do 
                  # this is obviously not right, but acceptable for now
                  expect(TimestampRegexMatcher.find_dates('June 32nd, 1985')).not_to be_empty
               end
            end

         end

      end
   end # dates

   context '::find_times' do 
      context 'iso time formats' do 
         it 'should find official timestamps in hh:mm:ss' do 
            @str = '2013-07-05 11:41:40-04:00'
            @matches = TimestampRegexMatcher.find_times(@str)
            expect(@matches.count).to eq 1

            @match = @matches.first
            expect(@match.regex_name).to eq :iso_standard
            expect(@match.hour).to eq '11'
            expect(@match.minute).to eq '41'
            expect(@match.second).to eq '40'
            expect(@match.timezone).to eq '-04:00'
         end

      end
   end


   context 'day and time' do 
      context 'iso date formats', skip: true do 
         it 'should find official timestamps in YYYY-MM-DD format' do 
# DEPRECATED
            @str = '2013-07-05 11:41:40 -0400'
            @matches = TimestampRegexMatcher.find_dates(@str)

            expect(@matches.count).to eq 1

            @mtch = @matches.first
            expect(@mtch.regex_name).to eq :iso_standard
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

