defmodule Microformats2.NestingTest do
  use ExUnit.Case

  test "real-world nesting example" do
    {:ok, str} = File.read("./test/documents/real_world_nesting.html")

    assert %{
             "items" => [
               %{
                 "properties" => %{
                   "author" => [
                     %{
                       "properties" => %{
                         "name" => ["Zachary Dunn"],
                         "nickname" => ["zack"],
                         "photo" => [
                           %{
                             "alt" => "Zachary Dunn's avatar.",
                             "value" => "http://localhost/images/avatar.jpg"
                           }
                         ],
                         "url" => ["http://localhost/"]
                       },
                       "type" => ["h-card"],
                       "value" => "Zachary Dunn"
                     }
                   ],
                   "published" => ["2024-01-09 17:11:10Z"],
                   "repost-of" => [
                     %{
                       "properties" => %{
                         "category" => ["IndieWeb", "tech", "decentralization"],
                         "name" => ["gilest.org: Make the indie web easier"],
                         "url" => ["https://gilest.org/indie-easy.html"]
                       },
                       "type" => ["h-cite"],
                       "value" => "https://gilest.org/indie-easy.html"
                     }
                   ],
                   "url" => ["https://adhoc.systems/boosts/51052d4f-a968-4a72-9150-225134e90423"]
                 },
                 "type" => ["h-entry"]
               }
             ],
             "rel-urls" => %{
               "http://localhost/" => %{
                 "rels" => ["index", "feed", "me"],
                 "text" => "Adhoc Systems",
                 "title" => "Index",
                 "type" => "text/html"
               },
               "http://localhost/articles" => %{
                 "rels" => ["feed"],
                 "title" => "Articles - Adhoc Systems",
                 "type" => "text/html"
               },
               "http://localhost/bookmarks" => %{
                 "rels" => ["feed"],
                 "title" => "Bookmarks - Adhoc Systems",
                 "type" => "text/html"
               },
               "http://localhost/boosts" => %{
                 "rels" => ["feed"],
                 "title" => "Boosts - Adhoc Systems",
                 "type" => "text/html"
               },
               "http://localhost/css/base.css" => %{"rels" => ["stylesheet"]},
               "http://localhost/css/note.css" => %{"rels" => ["stylesheet"]},
               "http://localhost/css/print.css" => %{
                 "media" => "print",
                 "rels" => ["stylesheet"]
               },
               "http://localhost/css/pub.css" => %{"rels" => ["stylesheet"]},
               "http://localhost/css/scroll.css" => %{"rels" => ["stylesheet"]},
               "http://localhost/css/utils.css" => %{"rels" => ["stylesheet"]},
               "http://localhost/images/pint.svg" => %{"rels" => ["icon", "favicon"]},
               "http://localhost/likes" => %{
                 "rels" => ["feed"],
                 "title" => "Likes - Adhoc Systems",
                 "type" => "text/html"
               },
               "http://localhost/manifest.json" => %{"rels" => ["manifest"]},
               "http://localhost/micropub" => %{"rels" => ["micropub"]},
               "http://localhost/notes" => %{
                 "rels" => ["feed"],
                 "title" => "Notes - Adhoc Systems",
                 "type" => "text/html"
               },
               "http://localhost/photos" => %{
                 "rels" => ["feed"],
                 "title" => "Photos - Adhoc Systems",
                 "type" => "text/html"
               },
               "https://adhoc.systems/articles/feed.xml" => %{
                 "rels" => ["alternate"],
                 "title" => "Articles (RSS)",
                 "type" => "application/rss+xml"
               },
               "https://adhoc.systems/bookmarks/feed.xml" => %{
                 "rels" => ["alternate"],
                 "title" => "Bookmarks (RSS)",
                 "type" => "application/rss+xml"
               },
               "https://adhoc.systems/boosts/51052d4f-a968-4a72-9150-225134e90423" => %{
                 "rels" => ["alternate"],
                 "type" => "application/activity+json"
               },
               "https://adhoc.systems/boosts/feed.xml" => %{
                 "rels" => ["alternate"],
                 "text" => "\n            Boosts Feed (RSS)\n            \n          ",
                 "title" => "Boosts (RSS)",
                 "type" => "application/rss+xml"
               },
               "https://adhoc.systems/feed.xml" => %{
                 "rels" => ["alternate"],
                 "title" => "Index (RSS)",
                 "type" => "application/rss+xml"
               },
               "https://adhoc.systems/likes/feed.xml" => %{
                 "rels" => ["alternate"],
                 "title" => "Likes (RSS)",
                 "type" => "application/rss+xml"
               },
               "https://adhoc.systems/notes/feed.xml" => %{
                 "rels" => ["alternate"],
                 "title" => "Notes (RSS)",
                 "type" => "application/rss+xml"
               },
               "https://adhoc.systems/webmention" => %{"rels" => ["webmention"]},
               "https://aperture.p3k.io/microsub/150" => %{"rels" => ["microsub"]},
               "https://huffduffer.com/0x1C3B00DA" => %{"rels" => ["me"]},
               "https://indieauth.com/auth" => %{"rels" => ["authorization_endpoint"]},
               "https://tokens.indieauth.com/token" => %{"rels" => ["token_endpoint"]},
               "https://toot.cafe/@zack" => %{"rels" => ["me"]},
               "https://twitter.com/0x1C3B00DA" => %{"rels" => ["me"]},
               "https://webmention.io/adhoc.systems/xmlrpc" => %{"rels" => ["pingback"]}
             },
             "rels" => %{
               "alternate" => [
                 "https://adhoc.systems/boosts/51052d4f-a968-4a72-9150-225134e90423",
                 "https://adhoc.systems/feed.xml",
                 "https://adhoc.systems/notes/feed.xml",
                 "https://adhoc.systems/articles/feed.xml",
                 "https://adhoc.systems/boosts/feed.xml",
                 "https://adhoc.systems/likes/feed.xml",
                 "https://adhoc.systems/bookmarks/feed.xml"
               ],
               "authorization_endpoint" => ["https://indieauth.com/auth"],
               "favicon" => ["http://localhost/images/pint.svg"],
               "feed" => [
                 "http://localhost/",
                 "http://localhost/notes",
                 "http://localhost/articles",
                 "http://localhost/photos",
                 "http://localhost/boosts",
                 "http://localhost/likes",
                 "http://localhost/bookmarks"
               ],
               "icon" => ["http://localhost/images/pint.svg"],
               "index" => ["http://localhost/"],
               "manifest" => ["http://localhost/manifest.json"],
               "me" => [
                 "https://twitter.com/0x1C3B00DA",
                 "https://toot.cafe/@zack",
                 "https://huffduffer.com/0x1C3B00DA",
                 "http://localhost/"
               ],
               "micropub" => ["http://localhost/micropub"],
               "microsub" => ["https://aperture.p3k.io/microsub/150"],
               "pingback" => ["https://webmention.io/adhoc.systems/xmlrpc"],
               "stylesheet" => [
                 "http://localhost/css/base.css",
                 "http://localhost/css/pub.css",
                 "http://localhost/css/utils.css",
                 "http://localhost/css/scroll.css",
                 "http://localhost/css/print.css",
                 "http://localhost/css/note.css"
               ],
               "token_endpoint" => ["https://tokens.indieauth.com/token"],
               "webmention" => ["https://adhoc.systems/webmention"]
             }
           } == Microformats2.parse(str, "http://localhost")
  end
end
