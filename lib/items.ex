defmodule Microformats2.Items do
  import Microformats2.Helpers

  alias Microformats2.Items
  alias Microformats2.Items.Implied

  def parse(nodes, doc, url, opts, items \\ [])
  def parse([head | tail], doc, url, opts, items) when is_bitstring(head), do: parse(tail, doc, url, opts, items)
  def parse([head | tail], doc, url, opts, items), do: parse(tail, doc, url, opts, parse(head, doc, url, opts, items))
  def parse([], _, _, _, items), do: items

  def parse({_, _, children} = root, doc, url, opts, items) do
    root_classes =
      [root]
      |> attr_list()
      |> Enum.filter(&is_rootlevel?/1)
      |> Enum.sort()

    if not Enum.empty?(root_classes) do
      item =
        %{normalized_key("type", opts) => root_classes, normalized_key("properties", opts) => %{}}
        |> maybe_put_id(root, opts)

      entry =
        parse_sub(children, doc, url, opts, item)
        |> Implied.parse(root, url, doc, opts)

      items ++ [entry]
    else
      parse(children, doc, url, opts, items)
    end
  end

  defp maybe_put_id(item, root, opts) do
    id = Floki.attribute([root], "id") |> List.first()

    if present?(id),
      do: Map.put(item, normalized_key("id", opts), id),
      else: item
  end

  defp parse_sub([], _, _, _, item), do: item

  defp parse_sub([child | children], doc, url, opts, item) when is_bitstring(child),
    do: parse_sub(children, doc, url, opts, item)

  defp parse_sub([child = {_, _, child_children} | children], doc, url, opts, item) do
    p =
      if has_a?([child], "h") do
        parse(child, doc, url, opts, []) |> List.first()
      else
        []
      end

    classes =
      [child]
      |> attr_list()
      |> Enum.filter(&non_h_type?/1)

    props = gen_prop(child, classes, item, p, doc, url, opts)

    n_item =
      if is_rootlevel?(child),
        do: props,
        else: parse_sub(child_children, doc, url, opts, props)

    parse_sub(children, doc, url, opts, n_item)
  end

  defp maybe_parse_prop(type, child, doc, url, opts) do
    if valid_mf2_name?(type),
      do: parse_prop(type, child, doc, url, opts),
      else: nil
  end

  defp parse_prop("p-" <> _, child, _, _, _),
    do: Items.PProp.parsed_prop(child)

  defp parse_prop("u-" <> _, child, doc, url, opts),
    do: Items.UProp.parsed_prop(child, doc, url, opts)

  defp parse_prop("dt-" <> _, child, _, _, _),
    do: Items.DtProp.parsed_prop(child)

  defp parse_prop("e-" <> _, child = {_, _, children}, _, _, opts) do
    text =
      [child]
      |> cleanup_html()
      |> Floki.text()

    %{
      normalized_key("html", opts) => stripped_or_nil(Floki.raw_html(children)),
      normalized_key("value", opts) => stripped_or_nil(text)
    }
  end

  defp parse_prop(_, _, _, _, _), do: nil

  defp get_value(class, p, opts) do
    cond do
      is_a?(class, "p") and p[normalized_key("properties", opts)][normalized_key("name", opts)] != nil ->
        List.first(p[normalized_key("properties", opts)][normalized_key("name", opts)])

      is_a?(class, "u") and p[normalized_key("properties", opts)][normalized_key("url", opts)] != nil ->
        List.first(p[normalized_key("properties", opts)][normalized_key("url", opts)])

      # and p[:properties]["url"] != nil ->
      is_a?(class, "e") ->
        # TODO handle
        nil

      true ->
        # TODO handle
        nil
    end
  end

  defp gen_prop(child, classes, item, p, doc, url, opts) do
    props =
      Enum.reduce(classes, item[normalized_key("properties", opts)], fn class, acc ->
        prop =
          if is_rootlevel?(child),
            do: Map.put(p, normalized_key("value", opts), get_value(class, p, opts)),
            else: maybe_parse_prop(class, child, doc, url, opts)

        key = normalized_key(strip_prefix(class), opts)
        Map.update(acc, key, [prop], &(&1 ++ [prop]))
      end)

    if blank?(classes) and present?(p) and is_rootlevel?(child),
      do: Map.update(item, normalized_key("children", opts), [p], &(&1 ++ [p])),
      else: Map.put(item, normalized_key("properties", opts), props)
  end

  defp strip_prefix("p-" <> rest), do: rest
  defp strip_prefix("u-" <> rest), do: rest
  defp strip_prefix("dt-" <> rest), do: rest
  defp strip_prefix("e-" <> rest), do: rest
  defp strip_prefix(rest), do: rest

  def img_prop(img, url, doc, opts) do
    alt = Floki.attribute([img], "alt") |> List.first()
    src = Floki.attribute([img], "src") |> List.first()

    if present?(alt) and present?(src),
      do: %{normalized_key("alt", opts) => alt, normalized_key("value", opts) => abs_uri(src, url, doc)},
      else: abs_uri(src, url, doc)
  end
end
