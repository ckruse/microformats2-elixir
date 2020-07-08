defmodule Microformats2.Suite.HCardTest do
  use ExUnit.Case

  import Microformats2.TestUtils

  test "baseurl" do
    {html, json} = suite_document("h-card/baseurl")
    assert Microformats2.parse(html, "http://example.com", atomize_keys: false, underscore_keys: false) == json
  end

  test "childimplied" do
    {html, json} = suite_document("h-card/childimplied")
    assert Microformats2.parse(html, "http://example.com", atomize_keys: false, underscore_keys: false) == json
  end

  test "extendeddescription" do
    {html, json} = suite_document("h-card/extendeddescription")
    assert Microformats2.parse(html, "http://example.com", atomize_keys: false, underscore_keys: false) == json
  end

  test "hcard" do
    {html, json} = suite_document("h-card/hcard")
    assert Microformats2.parse(html, "http://example.com", atomize_keys: false, underscore_keys: false) == json
  end

  test "hyperlinkedphoto" do
    {html, json} = suite_document("h-card/hyperlinkedphoto")
    assert Microformats2.parse(html, "http://example.com", atomize_keys: false, underscore_keys: false) == json
  end

  test "impliedname" do
    {html, json} = suite_document("h-card/impliedname")
    assert Microformats2.parse(html, "http://example.com", atomize_keys: false, underscore_keys: false) == json
  end

  test "impliedphoto" do
    {html, json} = suite_document("h-card/impliedphoto")
    assert Microformats2.parse(html, "http://example.com", atomize_keys: false, underscore_keys: false) == json
  end

  test "impliedurl" do
    {html, json} = suite_document("h-card/impliedurl")
    assert Microformats2.parse(html, "http://example.com", atomize_keys: false, underscore_keys: false) == json
  end

  test "impliedurlempty" do
    {html, json} = suite_document("h-card/impliedurlempty")
    assert Microformats2.parse(html, "http://example.com", atomize_keys: false, underscore_keys: false) == json
  end

  test "justahyperlink" do
    {html, json} = suite_document("h-card/justahyperlink")
    assert Microformats2.parse(html, "http://example.com", atomize_keys: false, underscore_keys: false) == json
  end

  test "justaname" do
    {html, json} = suite_document("h-card/justaname")
    assert Microformats2.parse(html, "http://example.com", atomize_keys: false, underscore_keys: false) == json
  end

  test "nested" do
    {html, json} = suite_document("h-card/nested")
    assert Microformats2.parse(html, "http://example.com", atomize_keys: false, underscore_keys: false) == json
  end

  test "p-property" do
    {html, json} = suite_document("h-card/p-property")
    assert Microformats2.parse(html, "http://example.com", atomize_keys: false, underscore_keys: false) == json
  end

  test "relativeurls" do
    {html, json} = suite_document("h-card/relativeurls")
    assert Microformats2.parse(html, "http://example.com", atomize_keys: false, underscore_keys: false) == json
  end

  test "relativeurlsempty" do
    {html, json} = suite_document("h-card/relativeurlsempty")
    assert Microformats2.parse(html, "http://example.com", atomize_keys: false, underscore_keys: false) == json
  end
end
