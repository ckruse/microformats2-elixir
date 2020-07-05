defmodule Microformats2.Suite.HProductTest do
  use ExUnit.Case

  import Microformats2.TestUtils

  test "aggregate" do
    {html, json} = suite_document("h-product/aggregate")
    assert Microformats2.parse(html, "http://example.com", atomize_keys: false, underscore_keys: false) == json
  end

  test "justahyperlink" do
    {html, json} = suite_document("h-product/justahyperlink")
    assert Microformats2.parse(html, "http://example.com", atomize_keys: false, underscore_keys: false) == json
  end

  test "simpleproperties" do
    {html, json} = suite_document("h-product/simpleproperties")
    assert Microformats2.parse(html, "http://example.com", atomize_keys: false, underscore_keys: false) == json
  end
end
