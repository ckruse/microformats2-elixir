defmodule Microformats2.Suite.HEntryTest do
  use ExUnit.Case

  import Microformats2.TestUtils

  test "encoding" do
    {html, json} = suite_document("h-entry/encoding")
    assert Microformats2.parse(html, "http://example.com", atomize_keys: false, underscore_keys: false) == json
  end

  test "impliedname" do
    {html, json} = suite_document("h-entry/impliedname")
    assert Microformats2.parse(html, "http://example.com", atomize_keys: false, underscore_keys: false) == json
  end

  test "impliedvalue-nested" do
    {html, json} = suite_document("h-entry/impliedvalue-nested")
    assert Microformats2.parse(html, "http://example.com", atomize_keys: false, underscore_keys: false) == json
  end

  test "justahyperlink" do
    {html, json} = suite_document("h-entry/justahyperlink")
    assert Microformats2.parse(html, "http://example.com", atomize_keys: false, underscore_keys: false) == json
  end

  test "justaname" do
    {html, json} = suite_document("h-entry/justaname")
    assert Microformats2.parse(html, "http://example.com", atomize_keys: false, underscore_keys: false) == json
  end

  test "scriptstyletags" do
    {html, json} = suite_document("h-entry/scriptstyletags")
    assert Microformats2.parse(html, "http://example.com", atomize_keys: false, underscore_keys: false) == json
  end

  test "summarycontent" do
    {html, json} = suite_document("h-entry/summarycontent")
    assert Microformats2.parse(html, "http://example.com", atomize_keys: false, underscore_keys: false) == json
  end

  test "u-property" do
    {html, json} = suite_document("h-entry/u-property")
    assert Microformats2.parse(html, "http://example.com", atomize_keys: false, underscore_keys: false) == json
  end

  test "urlincontent" do
    {html, json} = suite_document("h-entry/urlincontent")
    assert Microformats2.parse(html, "http://example.com", atomize_keys: false, underscore_keys: false) == json
  end
end
