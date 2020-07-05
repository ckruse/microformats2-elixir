defmodule Microformats2.Suite.HRecipeTest do
  use ExUnit.Case

  import Microformats2.TestUtils

  test "all" do
    {html, json} = suite_document("h-recipe/all")
    assert Microformats2.parse(html, "http://example.com", atomize_keys: false, underscore_keys: false) == json
  end

  test "minimum" do
    {html, json} = suite_document("h-recipe/all")
    assert Microformats2.parse(html, "http://example.com", atomize_keys: false, underscore_keys: false) == json
  end
end
