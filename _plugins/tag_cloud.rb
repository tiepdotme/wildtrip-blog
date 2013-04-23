# Copyright (C) 2011 Anurag Priyam - MIT License

module Jekyll

  # Jekyll plugin to generate tag clouds.
  #
  # The plugin defines a `tag_cloud` tag that is rendered by Liquid into a tag
  # cloud:
  #
  #     <div class='cloud'>
  #         {% tag_cloud %}
  #     </div>
  #
  # The tag cloud itself is a collection of anchor tags, styled dynamically
  # with the `font-size` CSS property. The range of values, and unit to use for
  # `font-size` can be specified with a very simple syntax:
  #
  #     {% tag_cloud font-size: 16 - 28px %}
  #
  # The output is automatically formatted to use the same number of decimal
  # places as used in the argument:
  #
  #     {% tag_cloud font-size: 0.8  - 1.8em  %}  # => 1
  #     {% tag_cloud font-size: 0.80 - 1.80em %}  # => 2
  #
  # Tags that have been used less than a certain number of times can be
  # filtered out from the tag cloud with the optional `threshold` parameter:
  #
  #     {% tag_cloud threshold: 2%}
  #
  # Both the parameters can be easily clubbed together:
  #
  #     {% tag_cloud font-size: 50 - 150%, threshold: 2%}
  #
  # The plugin randomizes the order of tags every time the cloud is generated.
  class TagCloud < Liquid::Tag
    safe = true

    # tag cloud variables - these are setup in `initialize`
    attr_reader :size_min, :size_max, :precision, :unit, :threshold

    def initialize(name, params, tokens)
      # initialize default values
      @size_min, @size_max, @precision, @unit = 70, 170, 0, '%'
      @threshold                              = 1

      # process parameters
      @params = Hash[*params.split(/(?:: *)|(?:, *)/)]
      process_threshold(@params['threshold'])

      super
    end

    def render(context)
      # get an Array of [tag name, tag count] pairs
      count = context.registers[:site].tags.map do |name, posts|
        [name, posts.count] if posts.count >= threshold
      end

      # clear nils if any
      count.compact!

      # shuffle the [tag name, tag weight, tag count] pairs
      weight = count.sort_by { |k,v| v }.reverse

      # reduce the Array of [tag name, tag weight] pairs to HTML
      weight.reduce("") do |html, tag|
        name, count = tag
        name_url = name.delete(' ')
        # html << "<a style='font-size: #{size}#{unit}' href='/tags.html##{name}'>#{name}</a>\n"
        html << "<li><a href='/tag/#{name_url}'>#{name} <span>(#{count})</span></a></li>\n"
      end
    end

    private

    def process_threshold(param)
      /\d*/.match(param) do |m|
        @threshold = m[0].to_i
      end
    end
  end
end

Liquid::Template.register_tag('tag_cloud', Jekyll::TagCloud)
