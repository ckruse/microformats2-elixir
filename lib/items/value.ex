defmodule Microformats2.Items.Value do
  @moduledoc false
  import Microformats2.Helpers

  alias Microformats2.Items

  def get_value(class, p, child, doc, url, opts, state) do
    cond do
      is_a?(class, "p") and p[normalized_key("properties", opts)][normalized_key("name", opts)] != nil ->
        {List.first(p[normalized_key("properties", opts)][normalized_key("name", opts)]), state}

      is_a?(class, "u") and p[normalized_key("properties", opts)][normalized_key("url", opts)] != nil ->
        {List.first(p[normalized_key("properties", opts)][normalized_key("url", opts)]), state}

      # and p[:properties]["url"] != nil ->
      is_a?(class, "e") && p[normalized_key("value", opts)] != nil ->
        {p[normalized_key("value", opts)], state}

      true ->
        Items.parse_prop(class, child, doc, url, opts, state)
    end
  end

  def has_value?(%{value: _}), do: true
  def has_value?(_), do: false

  def parse_value_class(item, separator \\ "") do
    item
    |> try_value_class_items(separator)
    |> try_value_title_class_items(item, separator)
  end

  defp try_value_class_items(item, separator) do
    items = Floki.find(item, ">[class~=value]")

    if present?(items) do
      items
      |> Enum.map(&value_class_text_content/1)
      |> Enum.join(separator)
      |> stripped_or_nil()
    else
      nil
    end
  end

  defp try_value_title_class_items(nil, item, separator) do
    items = Floki.find(item, ">[class~=value-title]")

    if present?(items) do
      items
      |> Enum.map(&(Floki.attribute(&1, "title") |> List.first()))
      |> Enum.join(separator)
      |> stripped_or_nil()
    else
      nil
    end
  end

  defp try_value_title_class_items(content, _, _), do: content

  defp value_class_text_content({"img", _, _} = node),
    do: Floki.attribute([node], "alt")

  defp value_class_text_content({"data", _, _} = node) do
    value = Floki.attribute([node], "value") |> List.first()

    if is_nil(value),
      do: text_content(node),
      else: value
  end

  defp value_class_text_content({"abbr", _, _} = node) do
    value = Floki.attribute([node], "title") |> List.first()

    if is_nil(value),
      do: text_content(node),
      else: value
  end

  defp value_class_text_content({_, _, _} = node),
    do: text_content([node])

  defp value_class_text_content(str) when is_binary(str), do: str
  defp value_class_text_content(_), do: nil
end
