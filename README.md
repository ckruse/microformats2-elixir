# Microformats2

A [Microformats2](http://microformats.org/wiki/microformats-2) parser for Elixir.

## Installation

This parser is [available in Hex](https://hex.pm/packages/microformats2):

1. Add microformats2 to your list of dependencies in `mix.exs`:

   ```
   def deps do
     [{:microformats2, "~> 0.3.1"}]
   end
   ```

2. If you want to directly `parse` from URLs, add `tesla` to your list of dependencies in `mix.exs`:

   ```
   def deps do
     [{:microformats2, "~> 0.3.1"},
      {:tesla, "~> 1.3.0"}]
   end
   ```

3. I recommend [html5ever](https://hex.pm/packages/html5ever) for parsing since the modified mochiweb parser
   distributed by Floki is a bit buggy sometimes, especially with whitespaces. To do so add `html5ever` to your
   list of dependencies in `mix.exs`:

   ```
   def deps do
     [{:microformats2, "~> 0.3.1"},
      {:html5ever, "~> 0.8.0"}]
   end
   ```

   After that configure Floki to use `html5ever` in your `config.exs`:

   ```
   config :floki, :html_parser, Floki.HTMLParser.Html5ever
   ```

## Usage

Give the parser an HTML string and the URL it was fetched from:

    Microformats2.parse("""<div class="h-card">
      <img class="u-photo" alt="photo of Mitchell"
           src="https://webfwd.org/content/about-experts/300.mitchellbaker/mentor_mbaker.jpg"/>
      <a class="p-name u-url"
         href="http://blog.lizardwrangler.com/">Mitchell Baker</a>
      (<a class="u-url" href="https://twitter.com/MitchellBaker">@MitchellBaker</a>)
      <span class="p-org">Mozilla Foundation</span>
      <p class="p-note">
        Mitchell is responsible for setting the direction and scope of the Mozilla Foundation and its activities.
      </p>
      <span class="p-category">Strategy</span>
      <span class="p-category">Leadership</span>
    </div>
    """, "http://localhost")

It will parse the object to a structure like that:

    %{
      rels: _,
      rel_urls: _,
      items: [
        %{
          type: ["h-card"],
          properties: %{
            "photo" => ["https://webfwd.org/content/about-experts/300.mitchellbaker/mentor_mbaker.jpg"],
            "name" => ["Mitchell Baker"],
            "url" => ["http://blog.lizardwrangler.com/", "https://twitter.com/MitchellBaker"],
            "org" => ["Mozilla Foundation"],
            "note" => [
              "Mitchell is responsible for setting the direction and scope of the Mozilla Foundation and its activities."
            ],
            "category" => ["Strategy", "Leadership"]
          }
        }
      ]
    }

You can also provide HTML trees already parsed with Floki:

    Microformats2.parse(Floki.parse("""<div class="h-card">...</div>"""), "http://localhost")

Or URLs if you have Tesla installed:

    Microformats2.parse("http://localhost")

## Dependencies

We need [Floki](https://github.com/philss/floki) for HTML parsing and
[Tesla](https://github.com/teamon/tesla) for fetching URLs.

## Features

Implemented:

- [parsing depth first, doc order](http://microformats.org/wiki/microformats2-parsing#parse_a_document_for_microformats)
- [parsing a p- property](http://microformats.org/wiki/microformats2-parsing#parsing_a_p-_property)
- [parsing a u- property](http://microformats.org/wiki/microformats2-parsing#parsing_a_u-_property)
- [parsing a dt- property](http://microformats.org/wiki/microformats2-parsing#parsing_a_dt-_property)
- [parsing a e- property](http://microformats.org/wiki/microformats2-parsing#parsing_an_e-_property)
- [parsing implied properties](http://microformats.org/wiki/microformats-2-parsing#parsing_for_implied_properties)
- nested properties
- nested microformat with associated property
- dynamic creation of properties
- [rel](http://microformats.org/wiki/rel)
- nested microformat without associated property
- [normalize u-\* property values](http://microformats.org/wiki/microformats2-parsing-faq#normalizing_u-.2A_property_values)

Not implemented:

- [value-class-pattern](http://microformats.org/wiki/value-class-pattern)
- [include-pattern](http://microformats.org/wiki/include-pattern)
- recognition of [vendor extensions](http://microformats.org/wiki/microformats2#VENDOR_EXTENSIONS)
- backwards compatible support for microformats v1

## License

This software is licensed under the [MIT license](https://choosealicense.com/licenses/mit/).
