defmodule Microformats2.Suite.HAddrTest do
  use ExUnit.Case

  import Microformats2.TestUtils

  test "geo" do
    {html, json} = suite_document("h-adr/geo")
    assert Microformats2.parse(html, "http://example.com", atomize_keys: false, underscore_keys: false) == json
  end

  test "geourl" do
    {html, json} = suite_document("h-adr/geourl")
    assert Microformats2.parse(html, "http://example.com", atomize_keys: false, underscore_keys: false) == json
  end

  test "justaname" do
    {html, json} = suite_document("h-adr/justaname")
    assert Microformats2.parse(html, "http://example.com", atomize_keys: false, underscore_keys: false) == json
  end

  test "lettercase" do
    {html, json} = suite_document("h-adr/lettercase")
    assert Microformats2.parse(html, "http://example.com", atomize_keys: false, underscore_keys: false) == json
  end

  test "simpleproperties" do
    {html, json} = suite_document("h-adr/simpleproperties")
    assert Microformats2.parse(html, "http://example.com", atomize_keys: false, underscore_keys: false) == json
  end
end
