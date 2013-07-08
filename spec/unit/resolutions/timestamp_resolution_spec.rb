require 'spec_helper'


# types: metadata, 
# published_on, 
# published_on text
# top of the post, bottom of the post, proximity to headline

# meant to be used on single post nodes
describe "TimestampResolver" do 

   context "parsing of HTML string" do 
      it "should find datetime in attribute"
      it 'should find datetime in singular textnode'
      it "should find datetime across split text nodes" 
   end



   context "prioritization of candidates" do
      before(:each) do 
         @str = %q{
            <div class="post"> 
               <div class="metadata">
               <div data-timefield="2013-07-07T14:12:14-04:00">
                  <span class='published_at'>3:00 AM on May 4th, 2010</span>
               </div>
               <h1>James was walking around 7/12/2003 4:00am when he heard of a big boom. Lorem*3</h1>

               <div>Lorem ipsum dolor sit amet, consectetur adipisicing elit. Ullam, enim temporibus commodi voluptate eos maxime aperiam expedita in sapiente. Qui, ipsam, fugit totam eveniet libero quia voluptatibus deserunt expedita quo.</div>
         <div>Nihil, molestias explicabo ullam mollitia Sept. 14, 1999 at 9:20PM magnam odio eveniet nisi. Quam, dolorum, ut, similique error soluta dolores vitae quas corporis nobis blanditiis repudiandae aperiam neque animi debitis ducimus alias repellat reiciendis!</div>
         <div>Quisquam, porro blanditiis iste aliquid consequatur ab expedita non. Labore, quis, dignissimos quas impedit nesciunt incidunt error adipisci voluptatibus voluptate nulla aspernatur eligendi provident beatae. Saepe, aliquid mollitia ex ipsam.</div>
               </div>

               
               <div class="bottom-data"><p>James posted this on June 12, 2006 14:00AM</p></div>  
            </div> 
         }
      end 
      it 'should prioritize datetime in attributes fields' 2013-07-07T14:12:14-04:00
      it 'should secondly prioritize datetime in specific date/time elements'  3:00 AM on May 4th, 2010 
      it 'should then prioritize datetime at top part of post element' 7/12/2003 4:00am
      it 'should then prioritize datetime at bottom part of post element' June 12, 2006 14:00AM
      it 'should least prioritize datetime found in middle of post' Sept. 14, 1999 at 9:20PM
   end
end

