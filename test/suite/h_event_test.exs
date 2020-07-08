defmodule Microformats2.Suite.HEventTest do
  use ExUnit.Case

  import Microformats2.TestUtils

  test "ampm" do
    {html, json} = suite_document("h-event/ampm")
    assert Microformats2.parse(html, "http://example.com", atomize_keys: false, underscore_keys: false) == json
  end

  test "attendees" do
    {html, json} = suite_document("h-event/attendees")
    assert Microformats2.parse(html, "http://example.com", atomize_keys: false, underscore_keys: false) == json
  end

  test "combining" do
    {html, json} = suite_document("h-event/combining")
    assert Microformats2.parse(html, "http://example.com", atomize_keys: false, underscore_keys: false) == json
  end

  test "concatenate" do
    {html, json} = suite_document("h-event/concatenate")
    assert Microformats2.parse(html, "http://example.com", atomize_keys: false, underscore_keys: false) == json
  end

  test "dates" do
    {html, json} = suite_document("h-event/dates")
    assert Microformats2.parse(html, "http://example.com", atomize_keys: false, underscore_keys: false) == json
  end

  test "dt-property" do
    {html, json} = suite_document("h-event/dt-property")
    assert Microformats2.parse(html, "http://example.com", atomize_keys: false, underscore_keys: false) == json
  end

  test "justahyperlink" do
    {html, json} = suite_document("h-event/justahyperlink")
    assert Microformats2.parse(html, "http://example.com", atomize_keys: false, underscore_keys: false) == json
  end

  test "justaname" do
    {html, json} = suite_document("h-event/justaname")
    assert Microformats2.parse(html, "http://example.com", atomize_keys: false, underscore_keys: false) == json
  end

  test "time" do
    {html, json} = suite_document("h-event/justaname")
    assert Microformats2.parse(html, "http://example.com", atomize_keys: false, underscore_keys: false) == json
  end
end
