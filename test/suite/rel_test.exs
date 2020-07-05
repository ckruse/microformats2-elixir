defmodule Microformats2.Suite.RelTest do
  use ExUnit.Case

  import Microformats2.TestUtils

  test "duplicate-rels" do
    {html, json} = suite_document("rel/duplicate-rels")
    assert Microformats2.parse(html, "http://example.com", atomize_keys: false, underscore_keys: false) == json
  end

  test "license" do
    {html, json} = suite_document("rel/license")
    assert Microformats2.parse(html, "http://example.com", atomize_keys: false, underscore_keys: false) == json
  end

  test "nofollow" do
    {html, json} = suite_document("rel/nofollow")
    assert Microformats2.parse(html, "http://example.com", atomize_keys: false, underscore_keys: false) == json
  end

  test "rel-urls" do
    {html, json} = suite_document("rel/rel-urls")
    assert Microformats2.parse(html, "http://example.com", atomize_keys: false, underscore_keys: false) == json
  end

  test "varying-text-duplicate-rels" do
    {html, json} = suite_document("rel/varying-text-duplicate-rels")
    assert Microformats2.parse(html, "http://example.com", atomize_keys: false, underscore_keys: false) == json
  end

  test "xfn-all" do
    {html, json} = suite_document("rel/xfn-all")
    assert Microformats2.parse(html, "http://example.com", atomize_keys: false, underscore_keys: false) == json
  end

  test "xfn-elsewhere" do
    {html, json} = suite_document("rel/xfn-all")
    assert Microformats2.parse(html, "http://example.com", atomize_keys: false, underscore_keys: false) == json
  end
end
