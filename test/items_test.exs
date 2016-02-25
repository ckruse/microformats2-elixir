defmodule Microformats2ItemsTest do
  use ExUnit.Case
  doctest Microformats2.Items

  test "successfully parses a whole document" do
    str = """
<!DOCTYPE html>
<html>
  <head>
    <title>Blub</title>
  </head>
  <body>
    <h1>Blah</h1>
    <article class="h-card">
      <span class="p-name">Luke <span>lulu</span></span>
      <a href="blub" class="u-url">blah</a>
    </article>
  </body>
</html>
"""

    ret = Microformats2.parse(str, "http://localhost")
    assert not Enum.empty?(ret[:items])
  end

  test "minimal h-card" do
    assert %{rels: _, rel_urls: _, items: [%{type: ["h-card"], properties: %{
                                                name: ["Frances Berriman"]}}]} =
      Microformats2.parse("<span class=\"h-card\">Frances Berriman</span>",
                          "http://localhost")

    assert %{rels: _, rel_urls: _, items: [%{type: ["h-card"], properties: %{
                                                name: ["Ben Ward"],
                                                url: ["http://benward.me"]}}]} =
      Microformats2.parse("<a class=\"h-card\" href=\"http://benward.me\">Ben Ward</a>",
                          "http://localhost")

    assert %{rels: _, rel_urls: _, items: [%{type: ["h-card"], properties: %{
                                                name: ["Rohit Khare"],
                                                url: ["http://rohit.khare.org/"],
                                                photo: ["https://s3.amazonaws.com/twitter_production/profile_images/53307499/180px-Rohit-sq_bigger.jpg"]}}]} =
      Microformats2.parse("""
<a class="h-card" href="http://rohit.khare.org/">
 <img alt="Rohit Khare"
      src="https://s3.amazonaws.com/twitter_production/profile_images/53307499/180px-Rohit-sq_bigger.jpg">
</a>
""",
                          "http://localhost")
  end

  test "successfully parses a h-card with author name" do
    {:ok, str} = File.read "./test/documents/h_card_with_author.html"

    assert %{rels: _, rel_urls: _, items: [%{type: ["h-card"], properties: %{
                                                photo: ["https://webfwd.org/content/about-experts/300.mitchellbaker/mentor_mbaker.jpg"],
                                                name: ["Mitchell Baker"],
                                                url: ["http://blog.lizardwrangler.com/",
                                                      "https://twitter.com/MitchellBaker"],
                                                org: ["Mozilla Foundation"],
                                                note: ["Mitchell is responsible for setting the direction and scope of the Mozilla Foundation and its activities."],
                                                category: ["Strategy",
                                                           "Leadership"]}}]} = Microformats2.parse(str, "http://localhost")
  end

  test "successfully parses a h-event combined with h-card" do
    {:ok, str} = File.read "./test/documents/h_event_combined_h_card.html"

    assert %{rels: _, rel_urls: _, items: [%{type: ["h-event"], properties: %{
                                                name: ["IndieWebCamp 2012"],
                                                url: ["http://indiewebcamp.com/2012"],
                                                start: ["2012-06-30"],
                                                end: ["2012-07-01"],
                                                location: [%{value: "Geoloqi",
                                                             type: ["h-card"],
                                                             properties: %{name: ["Geoloqi"],
                                                                           org: ["Geoloqi"],
                                                                           url: ["http://geoloqi.com/"],
                                                                           street_address: ["920 SW 3rd Ave. Suite 400"],
                                                                           locality: ["Portland"],
                                                                           region: ["Oregon"]}}]}}]} = Microformats2.parse(str, "http://localhost")
  end

  test "successfully parses a h-card with org" do
    {:ok, str} = File.read "./test/documents/h_card_org.html"

    assert %{rels: _, rel_urls: _, items: [%{type: ["h-card"], properties: %{
                                                name: ["Mitchell Baker"],
                                                url: ["http://blog.lizardwrangler.com/"],
                                                org: ["Mozilla Foundation"]}}]} = Microformats2.parse(str, "http://localhost")
  end

  test "successfully parses a h-card with h-card and org" do
    {:ok, str} = File.read "./test/documents/h_card_with_h_card_org.html"

    assert %{rels: _, rel_urls: _, items: [%{type: ["h-card"], properties: %{
                                                name: ["Mitchell Baker"],
                                                url: ["http://blog.lizardwrangler.com/"],
                                                org: [%{value: "Mozilla Foundation",
                                                        type: ["h-card"],
                                                        properties: %{
                                                          name: ["Mozilla Foundation"],
                                                          url: ["http://mozilla.org/"]}}]}}]} = Microformats2.parse(str, "http://localhost")
  end

  test "successfully parses a nested h-card h-org h-card" do
    {:ok, str} = File.read "./test/documents/nested_h_card_h_org_h_card.html"

    assert %{rels: _, rel_urls: _, items: [%{type: ["h-card"], properties: %{
                                                name: ["Mitchell Baker"],
                                                url: ["http://blog.lizardwrangler.com/"],
                                                org: [%{
                                                         value: "Mozilla Foundation",
                                                         type: ["h-card", "h-org"],
                                                         properties: %{
                                                           name: ["Mozilla Foundation"],
                                                           url: ["http://mozilla.org/"]}}]}}]} = Microformats2.parse(str, "http://localhost")
  end

  test "successfully parses a nested h-card w/o attached property" do
    {:ok, str} = File.read "./test/documents/h_card_org_h_card.html"

    assert %{rels: _, rel_urls: _, items: [%{type: ["h-card"], properties: %{
                                               name: ["Mitchell Baker"],
                                               url: ["http://blog.lizardwrangler.com/"]},
                                             children: [%{type: ["h-card"], properties: %{
                                                             name: ["Mozilla Foundation"],
                                                             url: ["http://mozilla.org/"]}}]}]} =
      Microformats2.parse(str, "http://localhost")
  end

  test "resolves explicit url to absolute URL" do
    assert %{rels: _, rel_urls: _, items: [%{type: ["h-card"], properties: %{
                                                name: ["Ben Ward"],
                                                url: ["http://benward.me/foo"]}}]} =
      Microformats2.parse("<div class=\"h-card\"><a class=\"u-url\" href=\"/foo\">Ben Ward</a></div>",
                          "http://benward.me")

    assert %{rels: _, rel_urls: _, items: [%{type: ["h-card"], properties: %{
                                                name: ["Ben Ward"],
                                                url: ["http://benward.me/foo"]}}]} =
      Microformats2.parse("<div class=\"h-card\"><a href=\"/foo\">Ben Ward</a></div>",
                          "http://benward.me")
  end

  test "jeena entry" do
    {:ok, str} = File.read "./test/documents/real_world_note.html"

    assert %{rels: _, rel_urls: _,
             items: [%{properties:
                       %{author: [%{properties: %{name: ["Jeena"],
                                                  photo: ["http://localhost/avatar.jpg"],
                                                  url: ["http://localhost/"]},
                                    type: ["h-card"], value: "Jeena"}],
                         comment: [%{properties: %{
                                        author: [%{properties: %{name: ["Christian Kruse"],
                                                                 photo: ["http://localhost/cache?size=40x40>&url=https%3A%2F%2Fwwwtech.de%2Fimages%2Fchristian-kruse-242470c34a3671da4cab3e3b0d941729.jpg%3Fvsn%3Dd"],
                                                                 url: ["https://wwwtech.de/notes/132"]},
                                                   type: ["h-card"],
                                                   value: "Christian Kruse"}],
                                        content: [%{html: "Of course he is!",
                                                    text: "Of course he is!"}],
                                        name: ["Christian Kruse,\n\t\t        4 days ago\n\t\t        Of course he is!"],
                                        published: ["2016-02-19T10:50:17Z"],
                                        url: ["https://wwwtech.de/notes/132"]}, type: ["h-cite"],
                                     value: "Christian Kruse,\n\t\t        4 days ago\n\t\t        Of course he is!"}],
                         content: [%{html: "<p>He's right, you know?</p>",
                                     text: "He's right, you know?"}],
                         in_reply_to: ["https://wwwtech.de/pictures/51"], name: ["Note #587"],
                         published: ["2016-02-18T19:33:25Z"], updated: ["2016-02-18T19:33:25Z"],
                         url: ["http://localhost/comments/587"]}, type: ["h-as-note", "h-entry"]}]} = Microformats2.parse(str, "http://localhost")
  end
end
