# Microformats2

A [Microformats2](http://microformats.org/wiki/microformats2) parser for Elixir.

## Installation

This parser is [available in Hex](https://hex.pm/packages/microformats2):

1. Add microformats2 to your list of dependencies in `mix.exs`:

   ```elixir
   def deps do
     [{:microformats2, "~> 0.7.2"}]
   end
   ```

2. If you want to directly `parse` from URLs, add `tesla` to your list of dependencies in `mix.exs`:

   ```elixir
   def deps do
     [{:microformats2, "~> 0.7.2"},
      {:tesla, "~> 1.4.1"}]
   end
   ```

## Usage

Give the parser an HTML string and the URL it was fetched from:

```elixir
Microformats2.parse("""
<div class="h-card">
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
""", "http://example.org")
```

It will parse the object to a structure like that:

```elixir
%{
  "items" => [
    %{
      "properties" => %{
        "category" => ["Strategy", "Leadership"],
        "name" => ["Mitchell Baker"],
        "note" => ["Mitchell is responsible for setting the direction and scope of the Mozilla Foundation and its activities."],
        "org" => ["Mozilla Foundation"],
        "photo" => [
          %{
            "alt" => "photo of Mitchell",
            "value" => "https://webfwd.org/content/about-experts/300.mitchellbaker/mentor_mbaker.jpg"
          }
        ],
        "url" => ["http://blog.lizardwrangler.com/",
         "https://twitter.com/MitchellBaker"]
      },
      "type" => ["h-card"]
    }
  ],
  "rel-urls" => %{},
  "rels" => %{}
}
```

You can also provide HTML trees already parsed with Floki:

```elixir
Microformats2.parse(Floki.parse("<div class=\"h-card\">...</div>"), "http://example.org")
```

Or URLs if you have Tesla installed:

```elixir
Microformats2.parse("http://example.org")
```

## Dependencies

We need [Floki](https://github.com/philss/floki) for HTML parsing and optionally
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
- [value-class-pattern](http://microformats.org/wiki/value-class-pattern)
- recognition of [vendor extensions](http://microformats.org/wiki/microformats2#VENDOR_EXTENSIONS)

Not implemented:

- [include-pattern](http://microformats.org/wiki/include-pattern)
- backwards compatible support for microformats v1

## License

This software is licensed under the [MIT license](https://choosealicense.com/licenses/mit/).
