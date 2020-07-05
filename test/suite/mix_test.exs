defmodule Microformats2.Suite.MixedTest do
  use ExUnit.Case

  import Microformats2.TestUtils

  test "id" do
    {html, json} = suite_document("mixed/id")
    assert Microformats2.parse(html, "http://example.com", atomize_keys: false, underscore_keys: false) == json
  end

  # TODO: fails because of value class pattern
  # test "ignoretemplate" do
  #   {html, json} = suite_document("mixed/ignoretemplate")
  #   assert Microformats2.parse(html, "http://example.com", atomize_keys: false, underscore_keys: false) == json
  # end

  test "vendorprefix" do
    {html, json} = suite_document("mixed/vendorprefix")
    assert Microformats2.parse(html, "http://example.com", atomize_keys: false, underscore_keys: false) == json
  end

  test "vendorprefixproperty" do
    {html, json} = suite_document("mixed/vendorprefixproperty")
    assert Microformats2.parse(html, "http://example.com", atomize_keys: false, underscore_keys: false) == json
  end
end
