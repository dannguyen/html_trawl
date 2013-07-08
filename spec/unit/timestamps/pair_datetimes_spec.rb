require 'spec_helper'

describe 'TimestampRegexMatcher.pair_datetimes' do 

   context 'proper order of date, then time' do 
      before(:each) do 
         @str = "The lazy brown dog jumped on January 21, 2012 at 9:20pm over the lazy dog"
         @date_matches = TimestampResolver.find_dates(@str)
         @time_matches = TimestampResolver.find_times(@str)
         @datetime_pairs = TimestampResolver.find_datetime_pairs(@str)
      end

      it 'should pair up the only date and time here' do 
         expect(@datetime_pairs.count ).to eq 1
      end

      context 'pair' do 
         before(:each) do 
            @pair = @datetime_pairs.first
            @date_match = @pair.date_match 
            @time_match = @pair.time_match
         end

         it 'should have a date string Mashie object in #date_match' do 
            expect(@date_match.regex_name).to eq :us_written
            expect(@date_match.year).to eq '2012'
            expect(@date_match.month).to eq 'January'
            expect(@date_match.regex_begin).to eq 29
            expect(@date_match.regex_end).to eq 45
            expect(@date_match.string_length).to eq (45-29)
         end

         it 'should have a date string Mashie object in #time_match' do 
            expect(@time_match.regex_name).to eq :us_written
            expect(@time_match.hour).to eq '9'
            expect(@time_match.minute).to eq '20'
            expect(@time_match.meridiem_suffix).to eq 'pm'
            expect(@time_match.timezone).to be_nil
            expect(@time_match.regex_begin).to eq 49
            expect(@time_match.regex_end).to eq 55
            expect(@time_match.string_length).to eq (55-49)
         end

         context 'Chronic resolution' do 
            expect(@pair.translated_datetime.to_s).to match '2012-01-21 21:20:00'
         end
      end
   end

   context 'different patterns for #translated_datetime' do 
      it 'should correctly parse a reverse order of time, then date' do 
          @str = "The lazy brown dog jumped on 12:20pm on May 21, 2012 over the lazy dog"
          @pair = TimestampResolver.find_datetime_pairs(@str).first 
          expect(@pair.translated_datetime.to_s).to match '2012-05-21 12:20:00'
      end 

      it 'should correctly parse ISO' do 
          @str = "The lazy brown dog jumped on 2013-07-07T14:12:14-04:00 over the lazy dog"
          @pair = TimestampResolver.find_datetime_pairs(@str).first 
          expect(@pair.translated_datetime.to_s).to eq '2013-07-07 14:12:14 -0400'
      end 

      it 'should correctly parse alternative ISO' do 
          @str = "The lazy brown dog jumped on 2013-07-07 00:12:14 +04:00 over the lazy dog"
          @pair = TimestampResolver.find_datetime_pairs(@str).first 
          expect(@pair.translated_datetime).to eq Chronic.parse '2013-07-07 00:12:14 +0400'
      end 
   end      


   context 'multiple pairs' do 
      it 'should detect double pairs'
      it 'should correctly match pairs'

   end
end