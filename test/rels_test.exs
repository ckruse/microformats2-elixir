defmodule Microformats2RelsTest do
  use ExUnit.Case
  doctest Microformats2.Rels

  test "parse successfully parses rels" do
    assert(
      %{items: _, rel_urls: %{"http://blub" => %{rels: ["me"], text: "blub"}}, rels: %{me: ["http://blub"]}} =
        Microformats2.parse("<a rel=\"me\" href=\"http://blub\">blub</a>", "http://localhost")
    )
  end

  test "parse successfully parses multiple rels" do
    assert(
      %{
        items: _,
        rel_urls: %{"http://blub" => %{rels: ["me"], text: "blub"}, "http://blah" => %{rels: ["me"], text: "blub"}},
        rels: %{me: ["http://blub", "http://blah"]}
      } =
        Microformats2.parse(
          """
          <a rel=\"me\" href=\"http://blub\">blub</a>
          <a rel=\"me\" href=\"http://blah\">blub</a>
          """,
          "http://localhost"
        )
    )
  end

  test "parse only saves one URL" do
    assert(
      %{items: _, rel_urls: %{"http://blub" => %{rels: ["me"], text: "blub"}}, rels: %{me: ["http://blub"]}} =
        Microformats2.parse(
          """
          <a rel=\"me\" href=\"http://blub\">blub</a>
          <a rel=\"me\" href=\"http://blub\">blub</a>
          """,
          "http://localhost"
        )
    )
  end

  test "parse saves all rels" do
    assert(
      %{
        items: _,
        rel_urls: %{"http://blub" => %{rels: ["me", "moo"], text: "blub"}},
        rels: %{me: ["http://blub"], moo: ["http://blub"]}
      } =
        Microformats2.parse(
          """
          <a rel=\"me\" href=\"http://blub\">blub</a>
          <a rel=\"moo\" href=\"http://blub\">blub</a>
          """,
          "http://localhost"
        )
    )
  end

  test "parse successfully parses rels with attributes" do
    assert(
      %{
        items: _,
        rel_urls: %{"http://blub" => %{rels: ["me"], media: "video", text: "blub"}},
        rels: %{me: ["http://blub"]}
      } = Microformats2.parse("<a rel=\"me\" media=\"video\" href=\"http://blub\">blub</a>", "http://localhost")
    )

    assert(
      %{
        items: _,
        rel_urls: %{"http://blub" => %{rels: ["me"], hreflang: "de", text: "blub"}},
        rels: %{me: ["http://blub"]}
      } = Microformats2.parse("<a rel=\"me\" hreflang=\"de\" href=\"http://blub\">blub</a>", "http://localhost")
    )

    assert(
      %{
        items: _,
        rel_urls: %{"http://blub" => %{rels: ["me"], title: "blub", text: "blub"}},
        rels: %{me: ["http://blub"]}
      } = Microformats2.parse("<a rel=\"me\" title=\"blub\" href=\"http://blub\">blub</a>", "http://localhost")
    )

    assert(
      %{
        items: _,
        rel_urls: %{"http://blub" => %{rels: ["me"], type: "text/html", text: "blub"}},
        rels: %{me: ["http://blub"]}
      } = Microformats2.parse("<a rel=\"me\" type=\"text/html\" href=\"http://blub\">blub</a>", "http://localhost")
    )

    assert(
      %{
        items: _,
        rel_urls: %{
          "http://blub" => %{
            rels: ["me"],
            media: "video",
            title: "blub",
            hreflang: "de",
            type: "text/html",
            text: "blub"
          }
        },
        rels: %{me: ["http://blub"]}
      } =
        Microformats2.parse(
          "<a rel=\"me\" hreflang=\"de\" media=\"video\" title=\"blub\" type=\"text/html\" href=\"http://blub\">blub</a>",
          "http://localhost"
        )
    )
  end

  test "duplicate value doesn't overwrite the first one" do
    assert(
      %{
        items: _,
        rel_urls: %{"http://blub" => %{rels: ["me"], text: "blub", hreflang: "de"}},
        rels: %{me: ["http://blub"]}
      } =
        Microformats2.parse(
          """
          <a rel="me" hreflang="de" href="http://blub">blub</a>
          <a rel="me" hreflang="en" href="http://blub">blah</a>
          """,
          "http://localhost"
        )
    )
  end

  test "parse ignores template elements" do
    assert(
      %{items: _, rel_urls: %{"http://blub" => %{rels: ["me"], text: "blub"}}, rels: %{me: ["http://blub"]}} =
        Microformats2.parse(
          """
          <a rel="me" href="http://blub">blub</a>
          <template><a rel="moo" href="http://blub">blub</a></template>
          """,
          "http://localhost"
        )
    )
  end

  test "parse generates an absolute URL" do
    assert(
      %{
        items: _,
        rel_urls: %{"http://localhost/blub" => %{rels: ["me"], text: "blub"}},
        rels: %{me: ["http://localhost/blub"]}
      } = Microformats2.parse("<a rel=\"me\" href=\"/blub\">blub</a>", "http://localhost")
    )

    assert(
      %{
        items: _,
        rel_urls: %{"http://localhost/blub" => %{rels: ["me"], text: "blub"}},
        rels: %{me: ["http://localhost/blub"]}
      } = Microformats2.parse("<a rel=\"me\" href=\"blub\">blub</a>", "http://localhost")
    )

    assert(
      %{
        items: _,
        rel_urls: %{"http://localhost/blah/blub" => %{rels: ["me"], text: "blub"}},
        rels: %{me: ["http://localhost/blah/blub"]}
      } = Microformats2.parse("<a rel=\"me\" href=\"blub\">blub</a>", "http://localhost/blah/foo")
    )

    assert(
      %{
        items: _,
        rel_urls: %{"http://localhost/blub" => %{rels: ["me"], text: "blub"}},
        rels: %{me: ["http://localhost/blub"]}
      } = Microformats2.parse("<a rel=\"me\" href=\"/blub\">blub</a>", "http://localhost/blah/foo")
    )
  end
end
