module HtmlTrawl
   class GeneratorResolver < Resolver



      def likely_cms 
         count_hsh = gather_cmses
         if count_hsh.empty?
            return nil
         else
            return count_hsh.sort_by{|k,v| v}[-1][0]
         end       
      end

      # https://github.com/nqbao/chromesniffer/blob/master/detector.js
      SITE_TESTS = {
         body: {
            'Drupal' => ->( noko_content ){ noko_content.css("node TODO") }

            },

         string: {
            'AlphaCMS' => { generator: /alphacms\s+(.*)/i },
            'Amiro.CMS' => { generator: /Amiro/i },
            'bbPress' => { generator: /bbPress/i },
            'BIGACE' => { generator: /BIGACE/i },
            'b2evolution' => {generator: /b2evolution/i},
            'Blogger' => { generator: /blogger/i, url: /\.blogspot\./i},
            'Blogsmith' => {asset_paths: /\/\/(?:www\.)?blogsmithmedia.com/i },
            'ClanSphere' => { generator: /ClanSphere/ },
            'CMSMadeSimple' => { generator: /CMS Made Simple/i },
            'concrete5' => { generator: /concrete5 -\s*(.*)$/ },
            'DataLifeEngine' => { generator: /DataLife Engine/ },
            'Drupal' => {generator: /Drupal/, js_code: /\bDrupal\./ },
            'DokuWiki' => { generator: /dokuWiki/i },
            'DotNetNuke' => { generator: /DotNetNuke/i },
            'ez Publish' => { generator: /eZ\s*Publish/i },
            'GetSimple' => { generator: /GetSimple/ },
            'JaliosJCMS' => { generator: /Jalios JCMS/i },
            'Joomla' => { generator: /joomla!?\s*([\d\.]+)?/i },
            'Koobi' => { generator: /koobi/i },
            'LiveJournal' => {asset_paths: /\/\/(?:www.|l-stat.)?livejournal.com/i },
            'MediaWiki' => { generator: /MediaWiki/i },
            'Movable Type' => { generator: /Movable Type/i },
            'OpenACS' => { generator: /OpenACS/i },
            'Octopress' => {file_names: /octopress.js/, full_head: /title=.?Octopress/ },
            'PHP-Nuke' => { generator: /PHP-Nuke/i },
            'phpBB' => { copyright: /phpBB/i },
            'PivotX' => { generator: /PivotX/i },
            'Plone' => { generator: /plone/i },
            'PrestaShop' => { generator: /PrestaShop/i },
            'SharePoint' => { generator: /SharePoint/ },
            'SilverStripe' => { generator: /SilverStripe/i },
            'Sitefinity' => { generator: /Sitefinity\s+(.*)/i },
            'TypePad' => { generator: /typepad\.com/i, url: /\.typepad\./i },
            'TYPO3' => { generator: /TYPO3/i },
            'Tumblr' => { url: /\.tumblr\./i,  
                           asset_paths: /(?:assets|static)\.tumblr/,  
                           full_text: /<iframe src=("|')http:\/\/\S+\.tumblr\.com/i },
            'vBulletin' => { generator: /vBulletin\s*(.*)/i, full_text: /vbmenu_control/ },
            'WebGUI' => { generator: /WebGUI/i },
            'Webnode' => { generator: /Webnode/ },
            'WordPress' => { 
                  generator: /WordPress\s*(.*)/i, 
                  url: /\.wordpress\./i, 
                  asset_paths: /wp-(?:content|includes)/ },
            'WPML' => { generator: /WPML/i },
            'XOOPS' => { generator: /xoops/i },
            'ZenCart' => { generator: /zen-cart/i }
         }
      }



   # returns a hash, with each key referring to an attribute, and the value referring to the archetype of that attribute
   #
   # e.g. 
   #
   # input: "...<meta name='generator' content='Wordpress 3.5.2'>..."

   #   {
   #      generator: 'WordPress'
   #   }
   #

   def determine_attributes_kind      
      myself = self 

      steps = {
         generator:  ->(){  detect_generator myself.meta_tags },

         [:css_paths, :asset_paths] => ->(){ myself.css_script_tags.to_html },

         [:js_paths, :asset_paths] => ->(){ myself.js_script_tags.to_html },

         :js_code => ->(){ myself.js_script_tags.text }

      }

      atts_hsh = { }

      steps.each_pair do |key, foo_html|
         if key.is_a?(Symbol)
            sym = key
            foo = key
         elsif key.is_a?(Array)
            sym, foo = key 
         end 
         
         if vals = foo_html.call() 
            det_foo = "determine_cms_from_#{foo}".to_sym
            atts_hsh[sym] = self.send det_foo, vals
         end
      end

      return atts_hsh
   end


   # calls determine_attributes_kind
   # returns a list of CMS and counts of attributes

      def gather_cmses
         atts_hsh = determine_attributes_kind 

         count_hsh = atts_hsh.values.inject(Hash.new{|h,k| h[k] = 0 }){ |hsh, val|
               hsh[val] += 1 unless val.nil?
               hsh
         }        
      end


      def _determine_cms_from_string_tests(test_sym, strings)

         arr = Array(strings)

         site_types = get_site_types_with(:string, test_sym)

         match_hsh = arr.inject(Hash.new{|h,k| h[k] = 0 }) do |hsh, path|
            site_types.each_pair do |k, regex|
               hsh[k] += 1 if path.match regex 
            end

            hsh
         end


         if match_hsh.keys.length == 1
            return match_hsh.keys[0]
         elsif match_hsh.empty?
            return nil
         else
            return match_hsh.sort_by{|x| x[1]}.reverse
         end
      end

      def method_missing(meth, *args, &block)
         if foo_name = meth.to_s.match(/^determine_cms_from_(\w+)$/)
            foo_name = $1
            send :_determine_cms_from_string_tests, foo_name.to_sym, *args
         else
            super 
         end
      end





      def js_script_tags
         @js_tags ||= @parsed_html.css('script')
      end


      def css_script_tags
         @css_tags  ||= @parsed_html.css("link[href*='.css']")
      end

      def head_tag 
         @h_tag ||= @parsed_html.css('head')
      end


      def meta_tags
         @metas ||= head_tag.css('meta')
      end  


      def detect_generator(content)
         if el = @parsed_html.css('meta[name="generator"]')[0]
            return el['content']
         end   
      end


      private 

      def get_site_types_with(foo_test, foo_sym)
         SITE_TESTS[foo_test].inject({}){ |hsh, (k,v)| hsh[k] = v[foo_sym] if v[foo_sym]; hsh }
      end

   end
end


