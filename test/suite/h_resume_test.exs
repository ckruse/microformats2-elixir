defmodule Microformats2.Suite.HResumeTest do
  use ExUnit.Case

  import Microformats2.TestUtils

  test "affiliation" do
    {html, json} = suite_document("h-resume/affiliation")
    assert Microformats2.parse(html, "http://example.com", atomize_keys: false, underscore_keys: false) == json
  end

  test "contact" do
    {html, json} = suite_document("h-resume/contact")
    assert Microformats2.parse(html, "http://example.com", atomize_keys: false, underscore_keys: false) == json
  end

  test "education" do
    {html, json} = suite_document("h-resume/education")
    assert Microformats2.parse(html, "http://example.com", atomize_keys: false, underscore_keys: false) == json
  end

  test "justaname" do
    {html, json} = suite_document("h-resume/justaname")
    assert Microformats2.parse(html, "http://example.com", atomize_keys: false, underscore_keys: false) == json
  end

  test "skill" do
    {html, json} = suite_document("h-resume/skill")
    assert Microformats2.parse(html, "http://example.com", atomize_keys: false, underscore_keys: false) == json
  end

  test "work" do
    {html, json} = suite_document("h-resume/work")
    assert Microformats2.parse(html, "http://example.com", atomize_keys: false, underscore_keys: false) == json
  end
end
