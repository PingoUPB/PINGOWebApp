# Copyright 2012 Insight Emissions Management Inc.
# 
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
# http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

module BootstrapHelper
  
  # Creats an icon wrapper based on Bootstrap.
  #
  # @param [String] name Icon name from Bootstrap's Glyphicons. Automatically prefixes the name
  #   with 'icon-' if not done already.
  # @param [Hash] options
  #
  # @option options [Boolean] white (false) Set to true if you want a white icon.
  # @option options [String] class ('') Set any classes you want for the icon here.
  #   a bit nicer.
  #
  # @return [HTML]
  #
  # @see http://twitter.github.com/bootstrap/base-css.html#icons Bootstrap Icons
  #
  def icon_tag name, options = {}
    options.reverse_merge!( white: false )
    name = name.to_s
    name.insert( 0, 'icon-' ) unless name.starts_with?( 'icon-' )  # Add prefix for bootstrap.
  
    klass = [name]
    klass << 'icon-white' if options[:white]
    options[:class] = klass.join( ' ' ) + options[:class].to_s
  
    content_tag(:i, nil, options) + " "
  end

  # Creates a tooltip alla Twitter Bootstrap.
  #
  # @param [String] anchor Anchor that people will hover over.
  # @param [Hash] options Specific options as well as any additional HTML options link_to accepts.
  #
  # @option [String] tip ('') Tip to be displayed on hover.  
  # @option [String] link Optionally pass in a link for when people click on the anchor text. We use
  #   this in Emission Central where we tell them that a feature is PRO feature and then clicking
  #   on the link creates an email to our support account.
  # @option []
  #
  # @return [HTML] link_to formatted correctly.
  #
  # @example Tooltip for an image.
  #   tooltip 'Imma tooltip!', tip: t('folder.private')
  #
  # @see #image_tag_with_tooltip Using an image as a tooltip.  
  #
  # @todo `tip` shouldn't be optional. It doesn't trigger if that's not set.
  #
  def tooltip anchor, options = {}
    options.reverse_merge!( tip: '', link: '#' )
    options.merge!( "data-original-title" => options.delete(:tip), rel: 'tooltip' )
    
    link_to anchor, options.delete(:link), options
  end

  # Creates a tooltip alla Twitter Bootstrap but instead of creating a link, it uses an image.
  #
  # @param [String] source Image location. Same as image_tag source.
  # @param [Hash] options 
  #
  # @option [String] tip ('') Tip to be displayed on hover.
  #
  # @see #tooltip Simple tooltip with just text.
  # @see #image_tag 
  #
  # @todo `tip` shouldn't be optional. It doesn't trigger if that's not set.
  #
  def image_tag_with_tooltip source, options = {}
    options.reverse_merge!( tip: '' )
    options.merge_nicely!( rel: 'tooltip', "data-original-title" => options.delete(:tip) )
    
    image_tag source, options
  end


  # Generates an alert alla Bootstrap.
  #
  # @param [String, HTML] msg Alert message to display.
  # @param [String, Symbol, Array<String,Symbol>] classes Extra alert classes to apply. Classes will
  #   automatically be prefixed with 'alert-' so no need to put that in there.
  #
  # @return [HTML]
  #
  # @see http://twitter.github.com/bootstrap/components.html#alerts Bootstrap Alerts
  # 
  def alert msg, classes = nil
    # Prefix classes with 'alert-' and format to string.
    classes = Array( classes ).collect{ |c| "alert-#{c}" }.join(' ')
  
    content_tag( :div, { :class => "alert #{classes}" } ) do
      link_to( 'x', '#', { 'class' => 'close' } ) +
      raw( msg )
    end
  end
  
  # Generates a label a la Bootstrap.
  #
  # @param [String] text Label text.
  # @param [Hash] options Class options and label style.
  #
  # @option options [String, Symbol] label_style (nil) Label style from Bootstrap. Possible choices
  #   are: `:success`, `:warning`, `:important`, `:info`, `inverse`
  #
  # @example White label.
  #   inline_label( 'Next Shutdown', label_style: 'white' )
  #
  # @todo Allow any html_options for options.
  # @todo Tests.
  #
  def inline_label text, options = {}
    klass = ['label']
    klass << options[:class].try(:split)

    
    label_style = options[:label_style].to_s
    label_style.insert(0, 'label-') unless label_style.blank? or label_style.starts_with?('label-')
    klass << label_style
    
    content_tag :span, text, class: klass.compact.join(' ')
  end
  
  # Generates a badge a la Bootstrap.
  #
  # @param [String] text Badge text.
  # @param [Hash] options Class options and badge style.
  #
  # @option options [String, Symbol] badge_style (nil) Badge style from Bootstrap. Possible choices
  #   are: `:success`, `:warning`, `:important`, `:info`, `inverse`
  #
  # @todo Allow any html_options for options.
  # @todo Tests.
  # @todo DRY this and #inline_label up.
  #
  # @see #inline_label
  #
  def badge text, options = {}
    klass = ['badge']
    klass << options[:class].try(:split)
    
    badge_style = options[:badge_style].to_s
    badge_style.insert(0, 'badge-') unless badge_style.blank? or badge_style.starts_with?('badge-')
    klass << badge_style
    
    content_tag :span, text, class: klass.compact.join(' ')
  end
  
end
