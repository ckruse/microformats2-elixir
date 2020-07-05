defmodule Microformats2.Suite.HFeedTest do
  use ExUnit.Case

  import Microformats2.TestUtils

  test "implied-title" do
    {html, json} = suite_document("h-feed/implied-title")
    assert Microformats2.parse(html, "http://example.com", atomize_keys: false, underscore_keys: false) == json
  end

  test "simple" do
    {html, json} = suite_document("h-feed/simple")
    assert Microformats2.parse(html, "http://example.com", atomize_keys: false, underscore_keys: false) == json
  end
end
