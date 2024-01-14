defmodule Microformats2.ItemsTest do
  use ExUnit.Case

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
    refute Enum.empty?(ret["items"])
  end

  test "minimal h-card" do
    assert %{
             "rels" => _,
             "rel-urls" => _,
             "items" => [%{"type" => ["h-card"], "properties" => %{"name" => ["Frances Berriman"]}}]
           } = Microformats2.parse("<span class=\"h-card\">Frances Berriman</span>", "http://localhost")

    assert %{
             "rels" => _,
             "rel-urls" => _,
             "items" => [
               %{"type" => ["h-card"], "properties" => %{"name" => ["Ben Ward"], "url" => ["http://benward.me"]}}
             ]
           } = Microformats2.parse("<a class=\"h-card\" href=\"http://benward.me\">Ben Ward</a>", "http://localhost")

    assert %{
             "rels" => _,
             "rel-urls" => _,
             "items" => [
               %{
                 "type" => ["h-card"],
                 "properties" => %{
                   "name" => ["Rohit Khare"],
                   "url" => ["http://rohit.khare.org/"],
                   "photo" => [
                     %{
                       "alt" => "Rohit Khare",
                       "value" =>
                         "https://s3.amazonaws.com/twitter_production/profile_images/53307499/180px-Rohit-sq_bigger.jpg"
                     }
                   ]
                 }
               }
             ]
           } =
             Microformats2.parse(
               """
               <a class="h-card" href="http://rohit.khare.org/">
                <img alt="Rohit Khare"
                     src="https://s3.amazonaws.com/twitter_production/profile_images/53307499/180px-Rohit-sq_bigger.jpg">
               </a>
               """,
               "http://localhost"
             )
  end

  test "successfully parses a h-card with author name" do
    {:ok, str} = File.read("./test/documents/h_card_with_author.html")

    assert %{
             "rels" => _,
             "rel-urls" => _,
             "items" => [
               %{
                 "type" => ["h-card"],
                 "properties" => %{
                   "photo" => [
                     %{
                       "alt" => "photo of Mitchell",
                       "value" => "https://webfwd.org/content/about-experts/300.mitchellbaker/mentor_mbaker.jpg"
                     }
                   ],
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
           } = Microformats2.parse(str, "http://localhost")
  end

  test "successfully parses a h-event combined with h-card" do
    {:ok, str} = File.read("./test/documents/h_event_combined_h_card.html")

    assert %{
             "rels" => _,
             "rel-urls" => _,
             "items" => [
               %{
                 "type" => ["h-event"],
                 "properties" => %{
                   "name" => ["IndieWebCamp 2012"],
                   "url" => ["http://indiewebcamp.com/2012"],
                   "start" => ["2012-06-30"],
                   "end" => ["2012-07-01"],
                   "location" => [
                     %{
                       "value" => "Geoloqi",
                       "type" => ["h-card"],
                       "properties" => %{
                         "name" => ["Geoloqi"],
                         "org" => ["Geoloqi"],
                         "url" => ["http://geoloqi.com/"],
                         "street-address" => ["920 SW 3rd Ave. Suite 400"],
                         "locality" => ["Portland"],
                         "region" => ["Oregon"]
                       }
                     }
                   ]
                 }
               }
             ]
           } = Microformats2.parse(str, "http://localhost")
  end

  test "successfully parses a h-card with org" do
    {:ok, str} = File.read("./test/documents/h_card_org.html")

    assert %{
             "rels" => _,
             "rel-urls" => _,
             "items" => [
               %{
                 "type" => ["h-card"],
                 "properties" => %{
                   "name" => ["Mitchell Baker"],
                   "url" => ["http://blog.lizardwrangler.com/"],
                   "org" => ["Mozilla Foundation"]
                 }
               }
             ]
           } = Microformats2.parse(str, "http://localhost")
  end

  test "successfully parses a h-card with h-card and org" do
    {:ok, str} = File.read("./test/documents/h_card_with_h_card_org.html")

    assert %{
             "rels" => _,
             "rel-urls" => _,
             "items" => [
               %{
                 "type" => ["h-card"],
                 "properties" => %{
                   "name" => ["Mitchell Baker"],
                   "url" => ["http://blog.lizardwrangler.com/"],
                   "org" => [
                     %{
                       "value" => "Mozilla Foundation",
                       "type" => ["h-card"],
                       "properties" => %{"name" => ["Mozilla Foundation"], "url" => ["http://mozilla.org/"]}
                     }
                   ]
                 }
               }
             ]
           } = Microformats2.parse(str, "http://localhost")
  end

  test "successfully parses a nested h-card h-org h-card" do
    {:ok, str} = File.read("./test/documents/nested_h_card_h_org_h_card.html")

    assert %{
             "rels" => _,
             "rel-urls" => _,
             "items" => [
               %{
                 "type" => ["h-card"],
                 "properties" => %{
                   "name" => ["Mitchell Baker"],
                   "url" => ["http://blog.lizardwrangler.com/"],
                   "org" => [
                     %{
                       "value" => "Mozilla Foundation",
                       "type" => ["h-card", "h-org"],
                       "properties" => %{"name" => ["Mozilla Foundation"], "url" => ["http://mozilla.org/"]}
                     }
                   ]
                 }
               }
             ]
           } = Microformats2.parse(str, "http://localhost")
  end

  test "successfully parses a nested h-card w/o attached property" do
    {:ok, str} = File.read("./test/documents/h_card_org_h_card.html")

    assert %{
             "rels" => _,
             "rel-urls" => _,
             "items" => [
               %{
                 "type" => ["h-card"],
                 "properties" => %{"name" => ["Mitchell Baker"], "url" => ["http://blog.lizardwrangler.com/"]},
                 "children" => [
                   %{
                     "type" => ["h-card"],
                     "properties" => %{"name" => ["Mozilla Foundation"], "url" => ["http://mozilla.org/"]}
                   }
                 ]
               }
             ]
           } = Microformats2.parse(str, "http://localhost")
  end

  test "resolves explicit url to absolute URL" do
    assert %{
             "rels" => _,
             "rel-urls" => _,
             "items" => [
               %{"type" => ["h-card"], "properties" => %{"name" => ["Ben Ward"], "url" => ["http://benward.me/foo"]}}
             ]
           } =
             Microformats2.parse(
               "<div class=\"h-card\"><a class=\"u-url\" href=\"/foo\">Ben Ward</a></div>",
               "http://benward.me"
             )

    assert %{
             "rels" => _,
             "rel-urls" => _,
             "items" => [
               %{"type" => ["h-card"], "properties" => %{"name" => ["Ben Ward"], "url" => ["http://benward.me/foo"]}}
             ]
           } = Microformats2.parse("<div class=\"h-card\"><a href=\"/foo\">Ben Ward</a></div>", "http://benward.me")
  end

  test "jeena entry" do
    {:ok, str} = File.read("./test/documents/real_world_note.html")

    assert %{
             "rels" => _,
             "rel-urls" => _,
             "items" => [
               %{
                 "properties" => %{
                   "author" => [
                     %{
                       "properties" => %{
                         "name" => ["Jeena"],
                         "photo" => ["http://localhost/avatar.jpg"],
                         "url" => ["http://localhost/"]
                       },
                       "type" => ["h-card"],
                       "value" => "Jeena"
                     }
                   ],
                   "comment" => [
                     %{
                       "properties" => %{
                         "author" => [
                           %{
                             "properties" => %{
                               "name" => ["Christian Kruse"],
                               "photo" => [
                                 "http://localhost/cache?size=40x40>&url=https%3A%2F%2Fwwwtech.de%2Fimages%2Fchristian-kruse-242470c34a3671da4cab3e3b0d941729.jpg%3Fvsn%3Dd"
                               ],
                               "url" => ["https://wwwtech.de/notes/132"]
                             },
                             "type" => ["h-card"],
                             "value" => "Christian Kruse"
                           }
                         ],
                         "content" => [%{"html" => "Of course he is!", "value" => "Of course he is!"}],
                         "published" => ["2016-02-19T10:50:17Z"],
                         "url" => ["https://wwwtech.de/notes/132"]
                       },
                       "type" => ["h-cite"],
                       "value" =>
                         "Christian Kruse,\n\t\t        4 days ago\n\t        \n\n\n\t        \n\t\t        Of course he is!",
                       "id" => "w3832"
                     }
                   ],
                   "content" => [%{"html" => "<p>He&#39;s right, you know?</p>", "value" => "He's right, you know?"}],
                   "in-reply-to" => ["https://wwwtech.de/pictures/51"],
                   "name" => ["Note #587"],
                   "published" => ["2016-02-18T19:33:25Z"],
                   "updated" => ["2016-02-18T19:33:25Z"],
                   "url" => ["http://localhost/comments/587"]
                 },
                 "type" => ["h-as-note", "h-entry"]
               }
             ]
           } = Microformats2.parse(str, "http://localhost")
  end

  test "Aaron Parecki: https://aaronparecki.com/2018/12/17/7/blocking-domains" do
    {:ok, str} = File.read("./test/documents/blocking-domains.html")

    assert %{
             "items" => [
               %{
                 "properties" => %{
                   "author" => ["http://localhost/"],
                   "category" => ["webmention", "p3k", "block", "spam"],
                   "comment" => [
                     %{
                       "children" => [
                         %{
                           "properties" => %{"name" => ["@freakazoid"], "url" => ["https://retro.social/@freakazoid"]},
                           "type" => ["h-card"]
                         },
                         %{
                           "properties" => %{"name" => ["@aaronpk"], "url" => ["https://aaronparecki.com/aaronpk"]},
                           "type" => ["h-card"]
                         }
                       ],
                       "properties" => %{
                         "author" => [
                           %{
                             "properties" => %{
                               "name" => ["Jacky Alciné"],
                               "photo" => [
                                 "https://pkcdn.xyz/playvicious.social/9b9144f41aa329413223cc8779b82ed39e7256a5f28e1fdb1ea4e5e6c901cd47.png"
                               ],
                               "url" => ["https://playvicious.social/@jalcine"]
                             },
                             "type" => ["h-card"],
                             "value" => "Jacky Alciné"
                           }
                         ],
                         "content" => [
                           %{
                             "html" =>
                               "<p><span class=\"h-card\"><a href=\"https://retro.social/@freakazoid\" class=\"u-url\" rel=\"nofollow\">@<span>freakazoid</span></a></span> This is a case for handling an attack vector (in the realm of spam) from <span class=\"h-card\"><a href=\"https://aaronparecki.com/aaronpk\" class=\"u-url\" rel=\"nofollow\">@<span>aaronpk</span></a></span> on the topic <a href=\"https://aaronparecki.com/2018/12/17/7/blocking-domains\" rel=\"nofollow\"><span>https://</span><span>aaronparecki.com/2018/12/17/7/</span><span>blocking-domains</span></a></p>",
                             "value" =>
                               "@freakazoid This is a case for handling an attack vector (in the realm of spam) from @aaronpk on the topic https://aaronparecki.com/2018/12/17/7/blocking-domains"
                           }
                         ],
                         "name" => [
                           "@freakazoid This is a case for handling an attack vector (in the realm of spam) from @aaronpk on the topic https://aaronparecki.com/2018/12/17/7/blocking-domains"
                         ],
                         "published" => ["2018-12-17T21:56:53+00:00"],
                         "url" => ["https://playvicious.social/@jalcine/101258612771728535"]
                       },
                       "type" => ["h-cite"],
                       "value" =>
                         "@freakazoid This is a case for handling an attack vector (in the realm of spam) from @aaronpk on the topic https://aaronparecki.com/2018/12/17/7/blocking-domains"
                     },
                     %{
                       "properties" => %{
                         "author" => [
                           %{
                             "properties" => %{"name" => ["fireburn.ru"], "url" => ["https://fireburn.ru"]},
                             "type" => ["h-card"],
                             "value" => "fireburn.ru"
                           }
                         ],
                         "content" => [
                           %{
                             "html" =>
                               "<p>Finally there is a blocklist interface! Now I can send webmentions from myself and not block my domain.</p>\n<p>Do you plan on building a premoderation queue tied to Vouch support?</p>",
                             "value" =>
                               "Finally there is a blocklist interface! Now I can send webmentions from myself and not block my domain.\nDo you plan on building a premoderation queue tied to Vouch support?"
                           }
                         ],
                         "name" => [
                           "Finally there is a blocklist interface! Now I can send webmentions from myself and not block my domain.\nDo you plan on building a premoderation queue tied to Vouch support?"
                         ],
                         "published" => ["2018-12-18T09:45:49+03:00"],
                         "url" => ["https://fireburn.ru/reply/1545115549"]
                       },
                       "type" => ["h-cite"],
                       "value" =>
                         "Finally there is a blocklist interface! Now I can send webmentions from myself and not block my domain.\nDo you plan on building a premoderation queue tied to Vouch support?"
                     },
                     %{
                       "properties" => %{
                         "author" => [
                           %{
                             "properties" => %{"name" => ["chrisburnell.com"], "url" => ["https://chrisburnell.com"]},
                             "type" => ["h-card"],
                             "value" => "chrisburnell.com"
                           }
                         ],
                         "name" => ["Chris Burnell"],
                         "published" => ["2018-12-18T08:58:31-08:00"],
                         "url" => ["https://chrisburnell.com/"]
                       },
                       "type" => ["h-cite"],
                       "value" => "Chris Burnell"
                     }
                   ],
                   "content" => [
                     %{
                       "html" =>
                         "<p>For the past week or so, I&#39;ve been getting a series of Pingbacks from a spam blog that reposts a blog post a couple times a day as a new post each time. It&#39;s up to about 220 copies of the post, each one having sent me a Pingback, and each one showing up in my <a href=\"https://aaronparecki.com/2018/04/20/46/indieweb-reader-my-new-home-on-the-internet\">reader</a> as a notification, which also causes it to be sent to my phone.</p>\n\n  <img src=\"https://aaronparecki.com/2018/12/17/7/image-1.jpg\" alt=\"\"/>\n\n<p>Since I use <a href=\"https://webmention.io\">webmention.io</a> to handle my incoming Webmentions (and Pingbacks), this would be the best place to block the site, rather than filtering it out in my reader or my website. </p>\n<p>Webmention.io previously had no way to actually completely block a domain. As Webmentions have started growing in popularity, it&#39;s become obvious that we need more tools to combat spam and abuse. While this site was actually sending me Pingbacks, the same applies to Webmentions.</p>\n<p>Today I added a new feature to <a href=\"https://webmention.io\">webmention.io</a> to allow people to entirely block a domain, and delete any webmentions received from that domain. </p>\n\n  <img src=\"https://aaronparecki.com/2018/12/17/7/image-2.png\" alt=\"\"/>\n\n<p>From the dashboard, you can click the &quot;X&quot; on any recent webmention, or you can paste a URL from one you&#39;ve received in the past. You&#39;ll be taken to this screen where you can either delete just the one webmention, or entirely block the domain.</p>\n<p>Once you&#39;ve blocked the domain, it will show up in your blocklists page!</p>\n\n  <img src=\"https://aaronparecki.com/2018/12/17/7/image-3.png\" alt=\"\"/>\n\n<p>I hope this helps others keep out spam as well! I&#39;m sure looking forward to never seeing that notification on my phone again!</p><script src=\"https://codefund.io/scripts/86b8ca8e-c3f2-41ee-822b-2e8cff3201a3/embed.js?template=bottom-bar\" async=\"async\"></script>\n<div id=\"codefund_ad\"></div>",
                       "value" =>
                         "For the past week or so, I've been getting a series of Pingbacks from a spam blog that reposts a blog post a couple times a day as a new post each time. It's up to about 220 copies of the post, each one having sent me a Pingback, and each one showing up in my reader as a notification, which also causes it to be sent to my phone.\n\n  \n\nSince I use webmention.io to handle my incoming Webmentions (and Pingbacks), this would be the best place to block the site, rather than filtering it out in my reader or my website. \nWebmention.io previously had no way to actually completely block a domain. As Webmentions have started growing in popularity, it's become obvious that we need more tools to combat spam and abuse. While this site was actually sending me Pingbacks, the same applies to Webmentions.\nToday I added a new feature to webmention.io to allow people to entirely block a domain, and delete any webmentions received from that domain. \n\n  \n\nFrom the dashboard, you can click the \"X\" on any recent webmention, or you can paste a URL from one you've received in the past. You'll be taken to this screen where you can either delete just the one webmention, or entirely block the domain.\nOnce you've blocked the domain, it will show up in your blocklists page!\n\n  \n\nI hope this helps others keep out spam as well! I'm sure looking forward to never seeing that notification on my phone again!"
                     }
                   ],
                   "like" => [
                     %{
                       "properties" => %{
                         "author" => [
                           %{
                             "properties" => %{
                               "name" => ["Eddie Hinkle"],
                               "photo" => [
                                 "https://pkcdn.xyz/eddiehinkle.com/cf9f85e26d4be531bc908d37f69bff1c50b50b87fd066b254f1332c3553df1a8.jpg"
                               ],
                               "url" => ["https://eddiehinkle.com/"]
                             },
                             "type" => ["h-card"],
                             "value" => "Eddie Hinkle"
                           }
                         ],
                         "url" => ["https://eddiehinkle.com/2018/12/18/1/like/"]
                       },
                       "type" => ["h-cite"],
                       "value" =>
                         "https://pkcdn.xyz/eddiehinkle.com/cf9f85e26d4be531bc908d37f69bff1c50b50b87fd066b254f1332c3553df1a8.jpg \n                        Eddie Hinkle"
                     },
                     %{
                       "properties" => %{
                         "author" => [
                           %{
                             "properties" => %{
                               "name" => ["Vika"],
                               "photo" => [
                                 "https://pkcdn.xyz/fireburn.ru/2c643998489fa0cea4689c0a154470f6e133f3ea0547fcce463eaf99312f3e42.png"
                               ],
                               "url" => ["https://fireburn.ru/"]
                             },
                             "type" => ["h-card"],
                             "value" => "Vika"
                           }
                         ],
                         "url" => ["https://fireburn.ru/like/1545115461"]
                       },
                       "type" => ["h-cite"],
                       "value" =>
                         "https://pkcdn.xyz/fireburn.ru/2c643998489fa0cea4689c0a154470f6e133f3ea0547fcce463eaf99312f3e42.png \n                        Vika"
                     }
                   ],
                   "location" => [
                     %{
                       "properties" => %{
                         "latitude" => ["45.535544"],
                         "locality" => ["Portland"],
                         "longitude" => ["-122.621348"],
                         "region" => ["Oregon"]
                       },
                       "type" => ["h-adr"],
                       "value" =>
                         "Portland,\n        Oregon\n          \n      •\n              \n                    52°F"
                     }
                   ],
                   "name" => ["Blocking Domains in webmention.io"],
                   "published" => ["2018-12-17T13:24:28-08:00"],
                   "url" => ["https://aaronparecki.com/2018/12/17/7/blocking-domains"],
                   "pk-num-likes" => ["2"],
                   "pk-num-mentions" => ["1"],
                   "pk-num-replies" => ["2"]
                 },
                 "type" => ["h-entry"],
                 "id" => "post-id-46271"
               },
               %{
                 "properties" => %{
                   "bday" => ["--12-28"],
                   "callsign" => ["W7APK"],
                   "name" => ["Aaron Parecki"],
                   "note" => [
                     "Hi, I'm Aaron Parecki,  co-founder of\nIndieWebCamp.\nI maintain oauth.net, write and consult about OAuth, and\nam the editor of several W3C specifications. I record videos for local conferences and help run a podcast studio in Portland.\n\nI wrote 100 songs in 100 days! I've been tracking my location since 2008,\nand write down everything I eat and drink.\nI've spoken at conferences around the world about\nowning your data,\nOAuth,\nquantified self,\nand explained why R is a vowel. Read more."
                   ],
                   "org" => [
                     %{
                       "properties" => %{"name" => ["IndieWebCamp"], "url" => ["https://indieweb.org/"]},
                       "type" => ["h-card"],
                       "value" => "IndieWebCamp"
                     },
                     %{
                       "properties" => %{"name" => ["oauth.net"], "url" => ["https://oauth.net/"]},
                       "type" => ["h-card"],
                       "value" => "oauth.net"
                     },
                     %{
                       "properties" => %{
                         "name" => ["Okta"],
                         "photo" => ["http://localhost/images/okta.png"],
                         "role" => ["Developer Advocate"],
                         "url" => ["https://developer.okta.com/"]
                       },
                       "type" => ["h-card"],
                       "value" => "Okta"
                     },
                     %{
                       "properties" => %{
                         "name" => ["IndieWebCamp"],
                         "photo" => ["http://localhost/images/indiewebcamp.png"],
                         "role" => ["Founder"],
                         "url" => ["https://indieweb.org/"]
                       },
                       "type" => ["h-card"],
                       "value" => "IndieWebCamp"
                     },
                     %{
                       "properties" => %{
                         "name" => ["W3C"],
                         "photo" => ["http://localhost/images/w3c.png"],
                         "role" => ["Editor"],
                         "url" => ["https://www.w3.org/"]
                       },
                       "type" => ["h-card"],
                       "value" => "W3C"
                     },
                     %{
                       "properties" => %{
                         "name" => ["Stream PDX"],
                         "photo" => ["http://localhost/images/streampdx.png"],
                         "role" => ["Co-Founder"],
                         "url" => ["https://streampdx.com"]
                       },
                       "type" => ["h-card"],
                       "value" => "Stream PDX"
                     },
                     %{
                       "properties" => %{
                         "name" => ["backpedal.tv"],
                         "photo" => ["http://localhost/images/backpedal.png"],
                         "url" => ["https://backpedal.tv"]
                       },
                       "type" => ["h-card"],
                       "value" => "backpedal.tv"
                     }
                   ],
                   "photo" => ["http://localhost/images/profile.jpg"],
                   "uid" => ["http://localhost/"],
                   "url" => ["http://localhost/", "https://w7apk.com"]
                 },
                 "type" => ["h-card"]
               }
             ],
             "rel-urls" => %{
               "http://creativecommons.org/licenses/by/3.0/" => %{
                 "rels" => ["license"],
                 "text" => "Creative Commons Attribution 3.0 License"
               },
               "http://localhost/assets/admin.css" => %{"rels" => ["stylesheet"]},
               "http://localhost/assets/carbon.css" => %{"rels" => ["stylesheet"]},
               "http://localhost/assets/featherlight-1.5.0/featherlight.min.css" => %{"rels" => ["stylesheet"]},
               "http://localhost/assets/icomoon/style.css" => %{"rels" => ["stylesheet"]},
               "http://localhost/assets/pulse.css" => %{"rels" => ["stylesheet"]},
               "http://localhost/assets/story.css" => %{"rels" => ["stylesheet"]},
               "http://localhost/assets/styles.4.css" => %{"rels" => ["stylesheet"]},
               "http://localhost/assets/weather-icons/css/weather-icons.css" => %{"rels" => ["stylesheet"]},
               "http://localhost/key.txt" => %{"rels" => ["pgpkey"]},
               "http://localhost/semantic/2.2.6/semantic.min.css" => %{"rels" => ["stylesheet"], "type" => "text/css"},
               "http://localhost/site/styles.1.css" => %{"rels" => ["stylesheet"]},
               "https://aaronparecki.com/" => %{"rels" => ["openid.delegate"]},
               "https://aaronparecki.com/2018/12/17/7/blocking-domains" => %{
                 "rels" => ["nofollow"],
                 "text" => "https://aaronparecki.com/2018/12/17/7/blocking-domains"
               },
               "https://aaronparecki.com/2018/12/17/7/blocking-domains.as2" => %{
                 "rels" => ["alternate"],
                 "type" => "application/activity+json"
               },
               "https://aaronparecki.com/2018/12/17/7/blocking-domains.jf2" => %{
                 "rels" => ["alternate"],
                 "type" => "application/jf2+json"
               },
               "https://aaronparecki.com/2018/12/17/7/blocking-domains.json" => %{
                 "rels" => ["alternate"],
                 "type" => "application/mf2+json"
               },
               "https://aaronparecki.com/aaronpk" => %{"rels" => ["nofollow"], "text" => "@aaronpk"},
               "https://micro.blog/aaronpk" => %{"rels" => ["me"]},
               "https://openid.indieauth.com/openid" => %{"rels" => ["openid.server"]},
               "https://retro.social/@freakazoid" => %{"rels" => ["nofollow"], "text" => "@freakazoid"},
               "https://webmention.io/aaronpk/webmention" => %{"rels" => ["webmention"]},
               "sms:+15035678642" => %{"rels" => ["me"]}
             },
             "rels" => %{
               "alternate" => [
                 "https://aaronparecki.com/2018/12/17/7/blocking-domains.json",
                 "https://aaronparecki.com/2018/12/17/7/blocking-domains.jf2",
                 "https://aaronparecki.com/2018/12/17/7/blocking-domains.as2"
               ],
               "license" => ["http://creativecommons.org/licenses/by/3.0/"],
               "me" => ["sms:+15035678642", "https://micro.blog/aaronpk"],
               "nofollow" => [
                 "https://retro.social/@freakazoid",
                 "https://aaronparecki.com/aaronpk",
                 "https://aaronparecki.com/2018/12/17/7/blocking-domains"
               ],
               "openid.delegate" => ["https://aaronparecki.com/"],
               "openid.server" => ["https://openid.indieauth.com/openid"],
               "pgpkey" => ["http://localhost/key.txt"],
               "stylesheet" => [
                 "http://localhost/semantic/2.2.6/semantic.min.css",
                 "http://localhost/assets/icomoon/style.css",
                 "http://localhost/assets/weather-icons/css/weather-icons.css",
                 "http://localhost/assets/featherlight-1.5.0/featherlight.min.css",
                 "http://localhost/assets/admin.css",
                 "http://localhost/assets/pulse.css",
                 "http://localhost/assets/styles.4.css",
                 "http://localhost/site/styles.1.css",
                 "http://localhost/assets/carbon.css",
                 "http://localhost/assets/story.css"
               ],
               "webmention" => ["https://webmention.io/aaronpk/webmention"]
             }
           } = Microformats2.parse(str, "http://localhost")
  end

  test "invalid attrs" do
    str = File.read!("./test/documents/invalid-attrs.html")

    assert %{
             "items" => [
               %{
                 "properties" => %{
                   "author" => [
                     %{
                       "properties" => %{
                         "name" => ["Jacky Alciné"],
                         "photo" => ["http://localhost:9000/koype-dev/photos/floating/original_self-portrait.jpg"]
                       },
                       "type" => ["h-card"],
                       "value" => "http://localhost:9000/"
                     }
                   ],
                   "like-of" => [
                     %{
                       "properties" => %{
                         "name" => ["67efebc0.ngrok.io"],
                         "url" => ["http://67efebc0.ngrok.io/post/b5a600c5-98a0-4112-b2d5-9df7c600f5e2"]
                       },
                       "type" => ["h-cite"],
                       "value" => "http://67efebc0.ngrok.io/post/b5a600c5-98a0-4112-b2d5-9df7c600f5e2"
                     }
                   ],
                   "name" => ["Liked\n          Liked\n          \n            67efebc0.ngrok.io"],
                   "published" => ["2018-12-19T00:19:04.410503Z"],
                   "summary" => ["Liked\n          Liked\n          \n            67efebc0.ngrok.io"],
                   "uid" => ["http://localhost:9000/post/a4ab5c98-c476-4800-9f09-2f7f5a337f32"],
                   "updated" => ["2018-12-19 00:19:04.406330"],
                   "url" => ["http://localhost:9000/post/a4ab5c98-c476-4800-9f09-2f7f5a337f32"]
                 },
                 "type" => ["h-entry"]
               }
             ],
             "rel-urls" => %{
               "http://localhost:9000/" => %{
                 "rels" => ["me"],
                 "text" => "\n                \n                Jacky Alciné\n              "
               }
             },
             "rels" => %{"me" => ["http://localhost:9000/"]}
           } == Microformats2.parse(str, "http://localhost:9000")
  end

  test "uses symbols as keys" do
    {:ok, str} = File.read("./test/documents/h_card_with_author.html")

    assert %{
             rels: _,
             "rel-urls": _,
             items: [
               %{
                 type: ["h-card"],
                 properties: %{
                   photo: [
                     %{
                       alt: "photo of Mitchell",
                       value: "https://webfwd.org/content/about-experts/300.mitchellbaker/mentor_mbaker.jpg"
                     }
                   ],
                   name: ["Mitchell Baker"],
                   url: ["http://blog.lizardwrangler.com/", "https://twitter.com/MitchellBaker"],
                   org: ["Mozilla Foundation"],
                   note: [
                     "Mitchell is responsible for setting the direction and scope of the Mozilla Foundation and its activities."
                   ],
                   category: ["Strategy", "Leadership"]
                 }
               }
             ]
           } = Microformats2.parse(str, "http://localhost", atomize_keys: true)
  end

  test "uses underscores for keys" do
    {:ok, str} = File.read("./test/documents/no_name_implied.html")

    assert %{
             "items" => [
               %{
                 "properties" => %{
                   "author" => [
                     %{
                       "properties" => %{
                         "name" => ["https://v2.jacky.wtf/"],
                         "photo" => [
                           "http://localhost/system/accounts/avatars/000/014/320/original/4c1cd829292173f1.jpeg?1569308379"
                         ],
                         "url" => ["https://playvicious.social/@jalcine"]
                       },
                       "type" => ["h-card"],
                       "value" => "https://v2.jacky.wtf/"
                     }
                   ],
                   "comment" => [
                     %{
                       "children" => [
                         %{
                           "properties" => %{
                             "name" => ["@jalcine"],
                             "url" => ["https://playvicious.social/@jalcine"]
                           },
                           "type" => ["h-card"]
                         }
                       ],
                       "properties" => %{
                         "author" => [
                           %{
                             "properties" => %{
                               "name" => ["dirt"],
                               "photo" => [
                                 "http://localhost/system/accounts/avatars/000/027/046/original/19b99aeef0603a9c.jpeg?1574111810"
                               ],
                               "url" => ["https://lgbtq.cool/@dirt"]
                             },
                             "type" => ["h-card"],
                             "value" => "dirt"
                           }
                         ],
                         "content" => [
                           %{
                             "html" =>
                               "<p><span class=\"h-card\"><a href=\"https://playvicious.social/@jalcine\" class=\"u-url mention\" rel=\"nofollow noopener tag noreferrer\" target=\"_blank\">@<span>jalcine</span></a></span> sick</p>",
                             "value" => "@jalcine sick"
                           }
                         ],
                         "published" => ["2018-08-17T17:46:52+00:00"],
                         "uid" => ["https://lgbtq.cool/@dirt/100566827835587508"],
                         "url" => ["https://lgbtq.cool/@dirt/100566827835587508"]
                       },
                       "type" => ["h-cite"],
                       "value" =>
                         "Aug 17, 2018, 17:46\n\n\n\n\n\n\n\n\n\ndirt\n\n \n\n@dirt@lgbtq.cool\n\n\n\n\n\n@jalcine sick\n\n\n\n0"
                     }
                   ],
                   "content" => [
                     %{
                       "html" =>
                         "<p>Had this commissioned! ♥️♥️ <a href=\"https://playvicious.social/tags/mastoart\" class=\"mention hashtag\" rel=\"tag\">#<span>mastoart</span></a> <a href=\"https://playvicious.social/tags/art\" class=\"mention hashtag\" rel=\"tag\">#<span>art</span></a> <a href=\"https://playvicious.social/tags/comics\" class=\"mention hashtag\" rel=\"tag\">#<span>comics</span></a></p>",
                       "value" => "Had this commissioned! ♥️♥️ #mastoart #art #comics"
                     }
                   ],
                   "in_reply_to" => [
                     %{
                       "properties" => %{
                         "author" => [
                           %{
                             "properties" => %{
                               "name" => ["https://v2.jacky.wtf/"],
                               "photo" => [
                                 "http://localhost/system/accounts/avatars/000/014/320/original/4c1cd829292173f1.jpeg?1569308379"
                               ],
                               "url" => ["https://playvicious.social/@jalcine"]
                             },
                             "type" => ["h-card"],
                             "value" => "https://v2.jacky.wtf/"
                           }
                         ],
                         "content" => [
                           %{
                             "html" =>
                               "<p>Alright y&#39;all. So y&#39;all know how heavy I ride for Virgil Hawkins.</p><p>Only cosplayed once as him.</p>",
                             "value" =>
                               "Alright y'all. So y'all know how heavy I ride for Virgil Hawkins.Only cosplayed once as him."
                           }
                         ],
                         "published" => ["2018-08-08T04:04:07+00:00"],
                         "uid" => ["https://playvicious.social/@jalcine/100512631822420862"],
                         "url" => ["https://playvicious.social/@jalcine/100512631822420862"]
                       },
                       "type" => ["h-cite"],
                       "value" =>
                         "Aug 08, 2018, 04:04\n\n\n\n\n\n\n\n\n\nhttps://v2.jacky.wtf/\n\n \n\n@jalcine@playvicious.social\n\n\n\n\n\nAlright y'all. So y'all know how heavy I ride for Virgil Hawkins.Only cosplayed once as him.\n\n\n\n0"
                     }
                   ],
                   "published" => ["2018-08-08T04:57:21+00:00"],
                   "uid" => ["https://playvicious.social/@jalcine/100512841146408725"],
                   "url" => ["https://playvicious.social/@jalcine/100512841146408725"]
                 },
                 "type" => ["h-entry"]
               }
             ],
             "rel_urls" => %{
               "http://localhost/apple-touch-icon.png" => %{"rels" => ["apple-touch-icon"]},
               "http://localhost/favicon.ico" => %{
                 "rels" => ["icon"],
                 "type" => "image/x-icon"
               },
               "http://localhost/manifest.json" => %{"rels" => ["manifest"]},
               "http://localhost/mask-icon.svg" => %{"rels" => ["mask-icon"]},
               "http://localhost/packs/css/core/common-35971294.chunk.css" => %{
                 "media" => "all",
                 "rels" => ["stylesheet"]
               },
               "http://localhost/packs/css/flavours/glitch/common-53e62ea8.chunk.css" => %{
                 "media" => "all",
                 "rels" => ["stylesheet"]
               },
               "https://lgbtq.cool/@dirt" => %{
                 "rels" => ["noopener", "noreferrer"],
                 "text" => "\n\n\n\n\n\n\ndirt\n\n \n\n@dirt@lgbtq.cool\n\n\n\n"
               },
               "https://lgbtq.cool/@dirt/100566827835587508" => %{
                 "rels" => ["noopener", "noreferrer"],
                 "text" => "Aug 17, 2018, 17:46\n"
               },
               "https://playvicious.social/@jalcine" => %{
                 "rels" => ["noopener", "noreferrer", "nofollow", "tag"],
                 "text" => "\n\n\n\n\n\n\nhttps://v2.jacky.wtf/\n\n \n\n@jalcine@playvicious.social\n\n\n\n"
               },
               "https://playvicious.social/@jalcine/100512631822420862" => %{
                 "rels" => ["noopener", "noreferrer"],
                 "text" => "Aug 08, 2018, 04:04\n"
               },
               "https://playvicious.social/@jalcine/100512841146408725" => %{
                 "rels" => ["noopener", "noreferrer"],
                 "text" => "Aug 08, 2018, 04:57\n"
               },
               "https://playvicious.social/api/oembed.json?url=https%3A%2F%2Fplayvicious.social%2F%40jalcine%2F100512841146408725" =>
                 %{
                   "rels" => ["alternate"],
                   "type" => "application/json+oembed"
                 },
               "https://playvicious.social/tags/art" => %{
                 "rels" => ["tag"],
                 "text" => "#art"
               },
               "https://playvicious.social/tags/comics" => %{
                 "rels" => ["tag"],
                 "text" => "#comics"
               },
               "https://playvicious.social/tags/mastoart" => %{
                 "rels" => ["tag"],
                 "text" => "#mastoart"
               },
               "https://playvicious.social/users/jalcine/statuses/100512841146408725" => %{
                 "rels" => ["alternate"],
                 "type" => "application/activity+json"
               }
             },
             "rels" => %{
               "alternate" => [
                 "https://playvicious.social/api/oembed.json?url=https%3A%2F%2Fplayvicious.social%2F%40jalcine%2F100512841146408725",
                 "https://playvicious.social/users/jalcine/statuses/100512841146408725"
               ],
               "apple_touch_icon" => ["http://localhost/apple-touch-icon.png"],
               "icon" => ["http://localhost/favicon.ico"],
               "manifest" => ["http://localhost/manifest.json"],
               "mask_icon" => ["http://localhost/mask-icon.svg"],
               "nofollow" => ["https://playvicious.social/@jalcine"],
               "noopener" => [
                 "https://playvicious.social/@jalcine/100512631822420862",
                 "https://playvicious.social/@jalcine",
                 "https://playvicious.social/@jalcine/100512841146408725",
                 "https://lgbtq.cool/@dirt/100566827835587508",
                 "https://lgbtq.cool/@dirt"
               ],
               "noreferrer" => [
                 "https://playvicious.social/@jalcine/100512631822420862",
                 "https://playvicious.social/@jalcine",
                 "https://playvicious.social/@jalcine/100512841146408725",
                 "https://lgbtq.cool/@dirt/100566827835587508",
                 "https://lgbtq.cool/@dirt"
               ],
               "stylesheet" => [
                 "http://localhost/packs/css/core/common-35971294.chunk.css",
                 "http://localhost/packs/css/flavours/glitch/common-53e62ea8.chunk.css"
               ],
               "tag" => [
                 "https://playvicious.social/tags/mastoart",
                 "https://playvicious.social/tags/art",
                 "https://playvicious.social/tags/comics",
                 "https://playvicious.social/@jalcine"
               ]
             }
           } = Microformats2.parse(str, "http://localhost", underscore_keys: true)
  end

  test "doesn't imply a name" do
    {:ok, str} = File.read("./test/documents/no_name_implied.html")
    doc = Microformats2.parse(str, "http://localhost")

    assert %{
             "items" => [
               %{
                 "properties" => %{
                   "author" => _,
                   "comment" => _,
                   "content" => _,
                   "in-reply-to" => _,
                   "published" => _,
                   "uid" => _,
                   "url" => _
                 },
                 "type" => ["h-entry"]
               }
             ],
             "rel-urls" => _,
             "rels" => _
           } = doc

    refute Map.get(List.first(doc["items"]), "name")
  end
end
