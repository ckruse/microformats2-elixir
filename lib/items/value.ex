defmodule Microformats2.Items.Value do
  import Microformats2.Helpers

  alias Microformats2.Items

  def get_value(class, p, child, doc, url, opts) do
    cond do
      is_a?(class, "p") and p[normalized_key("properties", opts)][normalized_key("name", opts)] != nil ->
        List.first(p[normalized_key("properties", opts)][normalized_key("name", opts)])

      is_a?(class, "u") and p[normalized_key("properties", opts)][normalized_key("url", opts)] != nil ->
        List.first(p[normalized_key("properties", opts)][normalized_key("url", opts)])

      # and p[:properties]["url"] != nil ->
      is_a?(class, "e") && p[normalized_key("value", opts)] != nil ->
        p[normalized_key("value", opts)]

      true ->
        Items.parse_prop(class, child, doc, url, opts)
    end
  end

  def has_value?(%{value: _}), do: true
  def has_value?(_), do: false
end
