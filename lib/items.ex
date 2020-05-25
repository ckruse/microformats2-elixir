defmodule Microformats2.Items do
  import Microformats2.Helpers

  alias Microformats2.Items.ImpliedProperties

  def parse(nodes, doc, url, items \\ [])
  def parse([head | tail], doc, url, items) when is_bitstring(head), do: parse(tail, doc, url, items)
  def parse([head | tail], doc, url, items), do: parse(tail, doc, url, parse(head, doc, url, items))
  def parse([], _, _, items), do: items

  def parse({_, _, children} = root, doc, url, items) do
    root_classes =
      [root]
      |> attr_list()
      |> Enum.filter(&is_rootlevel?/1)
      |> Enum.sort()

    if not Enum.empty?(root_classes) do
      entry =
        parse_sub(children, doc, url, %{type: root_classes, properties: %{}})
        |> ImpliedProperties.parse(root, url, doc)

      items ++ [entry]
    else
      parse(children, doc, url, items)
    end
  end

  defp parse_sub([], _, _, item), do: item
  defp parse_sub([child | children], doc, url, item) when is_bitstring(child), do: parse_sub(children, doc, url, item)

  defp parse_sub([child = {_, _, child_children} | children], doc, url, item) do
    p =
      if has_a?([child], "h-") do
        parse(child, doc, url, []) |> List.first()
      else
        []
      end

    classes =
      [child]
      |> attr_list()
      |> Enum.filter(&non_h_type?/1)

    props = gen_prop(child, classes, item, p, doc, url)

    n_item =
      if is_rootlevel?(child),
        do: props,
        else: parse_sub(child_children, doc, url, props)

    parse_sub(children, doc, url, n_item)
  end

  defp maybe_parse_prop(type, child, doc, url) do
    if valid_mf2_name?(type),
      do: parse_prop(type, child, doc, url),
      else: nil
  end

  defp parse_prop("p-" <> _, child, _, _) do
    # TODO value pattern parsing
    {elem, _, _} = child
    title = Floki.attribute([child], "title") |> List.first()
    alt = Floki.attribute([child], "alt") |> List.first()

    cond do
      elem == "abbr" and present?(title) ->
        title

      elem == "img" and present?(alt) ->
        alt

      true ->
        text_content(child) |> String.trim()
    end
  end

  defp parse_prop("u-" <> _, child = {elem, _, _}, doc, url) do
    href = Floki.attribute([child], "href") |> List.first()
    src = Floki.attribute([child], "src") |> List.first()
    data = Floki.attribute([child], "data") |> List.first()
    poster = Floki.attribute([child], "poster") |> List.first()
    title = Floki.attribute([child], "title") |> List.first()
    value = Floki.attribute([child], "value") |> List.first()

    cond do
      Enum.member?(["a", "area"], elem) and present?(href) ->
        href

      Enum.member?(["img", "audio", "video", "source"], elem) and present?(src) ->
        src

      elem == "object" and present?(data) ->
        data

      elem == "video" and present?(poster) ->
        poster

      # TODO value-class-pattern at this position
      elem == "abbr" and present?(title) ->
        title

      Enum.member?(["data", "input"], elem) and present?(value) ->
        value

      true ->
        text_content(child) |> String.trim()
    end
    |> abs_uri(url, doc)
  end

  defp parse_prop("dt-" <> _, child = {elem, _, _}, _, _) do
    dt = Floki.attribute([child], "datetime")
    title = Floki.attribute([child], "title")
    value = Floki.attribute([child], "value")

    cond do
      Enum.member?(["time", "ins", "del"], elem) and present?(dt) ->
        dt |> List.first()

      elem == "abbr" and present?(title) ->
        title |> List.first()

      Enum.member?(["data", "input"], elem) and present?(value) ->
        value |> List.first()

      true ->
        text_content(child) |> String.trim()
    end
  end

  defp parse_prop("e-" <> _, child = {_, _, children}, _, _) do
    %{
      html: stripped_or_nil(Floki.raw_html(children)),
      text: stripped_or_nil(Floki.text([child]))
    }
  end

  defp parse_prop(_, _, _, _), do: nil

  defp get_value(class, p) do
    cond do
      is_a?(class, "p") and p[:properties]["name"] != nil ->
        List.first(p[:properties]["name"])

      is_a?(class, "u") and p[:properties]["url"] != nil ->
        List.first(p[:properties]["url"])

      # and p[:properties]["url"] != nil ->
      is_a?(class, "e") ->
        # TODO handle
        nil

      true ->
        # TODO handle
        nil
    end
  end

  defp gen_prop(child, classes, item, p, doc, url) do
    props =
      Enum.reduce(classes, item[:properties], fn class, acc ->
        prop =
          if is_rootlevel?(child),
            do: Map.put(p, :value, get_value(class, p)),
            else: maybe_parse_prop(class, child, doc, url)

        key = strip_prefix(class)
        Map.update(acc, key, [prop], &(&1 ++ [prop]))
      end)

    if blank?(classes) and present?(p) and is_rootlevel?(child),
      do: Map.update(item, :children, [p], &(&1 ++ [p])),
      else: Map.put(item, :properties, props)
  end

  defp strip_prefix("p-" <> rest), do: rest
  defp strip_prefix("u-" <> rest), do: rest
  defp strip_prefix("dt-" <> rest), do: rest
  defp strip_prefix("e-" <> rest), do: rest
  defp strip_prefix(rest), do: rest

  def text_content(child, text \\ "")

  def text_content(child = {elem, _, children}, text) do
    txt =
      if elem == "img" do
        alt = Floki.attribute([child], "alt")

        if !blank?(alt) do
          alt
        else
          Floki.attribute([child], "src")
        end
        |> List.first()
      else
        ""
      end

    Enum.reduce(children, text <> txt, &text_content/2)
  end

  def text_content(child, text) when is_bitstring(child), do: text <> child
end
