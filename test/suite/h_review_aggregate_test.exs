defmodule Microformats2.Suite.HReviewAggregateTest do
  use ExUnit.Case

  import Microformats2.TestUtils

  # TODO: fails because of value class pattern
  # test "hevent" do
  #   {html, json} = suite_document("h-review-aggregate/hevent")
  #   assert Microformats2.parse(html, "http://example.com", atomize_keys: false, underscore_keys: false) == json
  # end

  test "justahyperlink" do
    {html, json} = suite_document("h-review-aggregate/justahyperlink")
    assert Microformats2.parse(html, "http://example.com", atomize_keys: false, underscore_keys: false) == json
  end

  # TODO: fails because of value class pattern
  # test "simpleproperties" do
  #   {html, json} = suite_document("h-review-aggregate/simpleproperties")
  #   assert Microformats2.parse(html, "http://example.com", atomize_keys: false, underscore_keys: false) == json
  # end
end
