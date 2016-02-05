defmodule Microformats2Test do
  use ExUnit.Case
  doctest Microformats2

  test "parse successfully parses rels" do
    assert(Microformats2.parse("<a rel=\"me\" href=\"http://blub\">blub</a>") ==
      %{items: [],
        rel_urls: %{"http://blub" => ["me"]},
        rels: %{"me" => ["http://blub"]}})
  end

  test "parse successfully parses multiple rels" do
    assert(Microformats2.parse("""
<a rel=\"me\" href=\"http://blub\">blub</a>
<a rel=\"me\" href=\"http://blah\">blub</a>
""") ==
      %{items: [],
        rel_urls: %{"http://blub" => ["me"],
                    "http://blah" => ["me"]},
        rels: %{"me" => ["http://blub", "http://blah"]}})
  end

  test "parse only saves one URL" do
    assert(Microformats2.parse("""
<a rel=\"me\" href=\"http://blub\">blub</a>
<a rel=\"me\" href=\"http://blub\">blub</a>
""") ==
      %{items: [],
        rel_urls: %{"http://blub" => ["me"]},
        rels: %{"me" => ["http://blub"]}})
  end

  test "parse saves all rels" do
    assert(Microformats2.parse("""
<a rel=\"me\" href=\"http://blub\">blub</a>
<a rel=\"moo\" href=\"http://blub\">blub</a>
""") ==
      %{items: [],
        rel_urls: %{"http://blub" => ["me", "moo"]},
        rels: %{"me" => ["http://blub"],
                "moo" => ["http://blub"]}})
  end

  test "parse generates an absolute URL" do
    assert false, "TODO"
  end

end
