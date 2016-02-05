defmodule Microformats2Test do
  use ExUnit.Case
  doctest Microformats2

  test "parse successfully parses rels" do
    assert(Microformats2.parse("<a rel=\"me\" href=\"http://blub\">blub</a>") ==
      %{items: [],
        rel_urls: %{"http://blub" => %{ rels: ["me"], text: "blub" }},
        rels: %{"me" => ["http://blub"]}})
  end

  test "parse successfully parses multiple rels" do
    assert(Microformats2.parse("""
<a rel=\"me\" href=\"http://blub\">blub</a>
<a rel=\"me\" href=\"http://blah\">blub</a>
""") ==
      %{items: [],
        rel_urls: %{"http://blub" => %{ rels: ["me"], text: "blub" },
                    "http://blah" => %{ rels: ["me"], text: "blub" }},
        rels: %{"me" => ["http://blub", "http://blah"]}})
  end

  test "parse only saves one URL" do
    assert(Microformats2.parse("""
<a rel=\"me\" href=\"http://blub\">blub</a>
<a rel=\"me\" href=\"http://blub\">blub</a>
""") ==
      %{items: [],
        rel_urls: %{"http://blub" => %{rels: ["me"], text: "blub"}},
        rels: %{"me" => ["http://blub"]}})
  end

  test "parse saves all rels" do
    assert(Microformats2.parse("""
<a rel=\"me\" href=\"http://blub\">blub</a>
<a rel=\"moo\" href=\"http://blub\">blub</a>
""") ==
      %{items: [],
        rel_urls: %{"http://blub" => %{ rels: ["me", "moo"], text: "blub" }},
        rels: %{"me" => ["http://blub"],
                "moo" => ["http://blub"]}})
  end

  test "parse successfully parses rels with attributes" do
    assert(Microformats2.parse("<a rel=\"me\" media=\"video\" href=\"http://blub\">blub</a>") ==
      %{items: [],
        rel_urls: %{"http://blub" => %{ rels: ["me"], media: "video", text: "blub" }},
        rels: %{"me" => ["http://blub"]}})

    assert(Microformats2.parse("<a rel=\"me\" hreflang=\"de\" href=\"http://blub\">blub</a>") ==
      %{items: [],
        rel_urls: %{"http://blub" => %{ rels: ["me"], hreflang: "de", text: "blub" }},
        rels: %{"me" => ["http://blub"]}})

    assert(Microformats2.parse("<a rel=\"me\" title=\"blub\" href=\"http://blub\">blub</a>") ==
      %{items: [],
        rel_urls: %{"http://blub" => %{ rels: ["me"], title: "blub", text: "blub" }},
        rels: %{"me" => ["http://blub"]}})

    assert(Microformats2.parse("<a rel=\"me\" type=\"text/html\" href=\"http://blub\">blub</a>") ==
      %{items: [],
        rel_urls: %{"http://blub" => %{ rels: ["me"], type: "text/html", text: "blub" }},
        rels: %{"me" => ["http://blub"]}})

    assert(Microformats2.parse("<a rel=\"me\" hreflang=\"de\" media=\"video\" title=\"blub\" type=\"text/html\" href=\"http://blub\">blub</a>") ==
      %{items: [],
        rel_urls: %{"http://blub" => %{ rels: ["me"],
                                        media: "video",
                                        title: "blub",
                                        hreflang: "de",
                                        type: "text/html",
                                        text: "blub" }},
        rels: %{"me" => ["http://blub"]}})
  end


  test "parse generates an absolute URL" do
    assert false, "TODO"
  end

end
