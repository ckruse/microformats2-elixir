defmodule Microformats2.Suite.HGeoTest do
  use ExUnit.Case

  import Microformats2.TestUtils

  test "abbrpattern" do
    {html, json} = suite_document("h-geo/abbrpattern")
    assert Microformats2.parse(html, "http://example.com", atomize_keys: false, underscore_keys: false) == json
  end

  test "altitude" do
    {html, json} = suite_document("h-geo/altitude")
    assert Microformats2.parse(html, "http://example.com", atomize_keys: false, underscore_keys: false) == json
  end

  # TODO: fails because of value class pattern
  # test "hidden" do
  #   {html, json} = suite_document("h-geo/hidden")
  #   assert Microformats2.parse(html, "http://example.com", atomize_keys: false, underscore_keys: false) == json
  # end

  test "justaname" do
    {html, json} = suite_document("h-geo/justaname")
    assert Microformats2.parse(html, "http://example.com", atomize_keys: false, underscore_keys: false) == json
  end

  test "simpleproperties" do
    {html, json} = suite_document("h-geo/simpleproperties")
    assert Microformats2.parse(html, "http://example.com", atomize_keys: false, underscore_keys: false) == json
  end

  # TODO: fails because of value class pattern
  # test "valuetitleclass" do
  #   {html, json} = suite_document("h-geo/valuetitleclass")
  #   assert Microformats2.parse(html, "http://example.com", atomize_keys: false, underscore_keys: false) == json
  # end
end
