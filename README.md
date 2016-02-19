# Microformats2

A [Microformats2](http://microformats.org/wiki/microformats-2) parser for Elixir.

## Installation

Since it is not yet [available in Hex](https://hex.pm/), the package can only be installed via git:

  1. Add microformats2 to your list of dependencies in `mix.exs`:

        def deps do
          [{:microformats2, github: "ckruse/microformats2-elixir"}]
        end

Once the parser leaves beta it will be available on Hex.

## Usage

Give the parser an HTML string:

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
    """)

It will parse the object to a structure like that:

    %{rels: [],
      rel_urls: [],
      items: [%{type: ["h-card"],
                properties: %{photo: ["https://webfwd.org/content/about-experts/300.mitchellbaker/mentor_mbaker.jpg"],
                              name: ["Mitchell Baker"],
                              url: ["http://blog.lizardwrangler.com/",
                                    "https://twitter.com/MitchellBaker"],
                              org: ["Mozilla Foundation"],
                              note: ["Mitchell is responsible for setting the direction and scope of the Mozilla Foundation and its activities."],
                              category: ["Strategy",
                                         "Leadership"]}}]}

## Dependencies

We need [Floki](https://github.com/philss/floki) for HTML parsing.

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

Not implemented:

- [normalize u-* property values](http://microformats.org/wiki/microformats2-parsing-faq#normalizing_u-.2A_property_values)
- [value-class-pattern](http://microformats.org/wiki/value-class-pattern)
- [include-pattern](http://microformats.org/wiki/include-pattern)
- recognition of [vendor extensions](http://microformats.org/wiki/microformats2#VENDOR_EXTENSIONS)
- backwards compatible support for microformats v1

## License

This software is licensed under the [AGPL3](http://choosealicense.com/licenses/agpl-3.0/).
