defmodule Microformats2.Suite.HReviewTest do
  use ExUnit.Case

  import Microformats2.TestUtils

  test "hyperlink" do
    {html, json} = suite_document("h-review/hyperlink")
    assert Microformats2.parse(html, "http://example.com", atomize_keys: false, underscore_keys: false) == json
  end

  test "implieditem" do
    {html, json} = suite_document("h-review/implieditem")
    assert Microformats2.parse(html, "http://example.com", atomize_keys: false, underscore_keys: false) == json
  end

  test "item" do
    {html, json} = suite_document("h-review/item")
    assert Microformats2.parse(html, "http://example.com", atomize_keys: false, underscore_keys: false) == json
  end

  test "justaname" do
    {html, json} = suite_document("h-review/justaname")
    assert Microformats2.parse(html, "http://example.com", atomize_keys: false, underscore_keys: false) == json
  end

  test "photo" do
    {html, json} = suite_document("h-review/photo")
    assert Microformats2.parse(html, "http://example.com", atomize_keys: false, underscore_keys: false) == json
  end

  test "vcard" do
    {html, json} = suite_document("h-review/vcard")
    assert Microformats2.parse(html, "http://example.com", atomize_keys: false, underscore_keys: false) == json
  end
end
