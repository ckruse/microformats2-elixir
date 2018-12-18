defmodule Microformats2.Items do
  def parse(nodes, doc, url, items \\ [])
  def parse([head | tail], doc, url, items) when is_bitstring(head), do: parse(tail, doc, url, items)
  def parse([head | tail], doc, url, items), do: parse(tail, doc, url, parse(head, doc, url, items))
  def parse([], _, _, items), do: items

  def parse(root, doc, url, items) do
    root_classes =
      Microformats2.attr_list(root)
      |> Enum.filter(fn class_name -> Microformats2.is_rootlevel?(class_name) end)
      |> Enum.sort()

    {_, _, children} = root

    if not Enum.empty?(root_classes) do
      entry =
        parse_sub(children, doc, url, %{type: root_classes, properties: %{}})
        |> Microformats2.Items.ImpliedProperties.parse(root, url, doc)

      items ++ [entry]
    else
      parse(children, doc, url, items)
    end
  end

  defp parse_sub([], _, _, item), do: item
  defp parse_sub([child | children], doc, url, item) when is_bitstring(child), do: parse_sub(children, doc, url, item)

  defp parse_sub([child = {_, _, child_children} | children], doc, url, item) do
    p =
      if Microformats2.has_a?(child, "h-") do
        parse(child, doc, url, []) |> List.first()
      else
        []
      end

    classes =
      Microformats2.attr_list(child)
      |> Enum.filter(fn
        "p-" <> _ -> true
        "u-" <> _ -> true
        "dt-" <> _ -> true
        "e-" <> _ -> true
        _ -> false
      end)

    props = gen_prop(child, classes, item, p, doc, url)
    n_item = if Microformats2.is_rootlevel?(child), do: props, else: parse_sub(child_children, doc, url, props)

    parse_sub(children, doc, url, n_item)
  end

  defp parse_prop("p-" <> _, child, _, _) do
    # TODO value pattern parsing
    {elem, _, _} = child
    title = Floki.attribute(child, "title") |> List.first()
    alt = Floki.attribute(child, "alt") |> List.first()

    cond do
      elem == "abbr" and not Microformats2.blank?(title) ->
        title

      elem == "img" and not Microformats2.blank?(alt) ->
        alt

      true ->
        text_content(child) |> String.trim()
    end
  end

  defp parse_prop("u-" <> _, child = {elem, _, _}, doc, url) do
    href = Floki.attribute(child, "href") |> List.first()
    src = Floki.attribute(child, "src") |> List.first()
    data = Floki.attribute(child, "data") |> List.first()
    poster = Floki.attribute(child, "poster") |> List.first()
    title = Floki.attribute(child, "title") |> List.first()
    value = Floki.attribute(child, "value") |> List.first()

    cond do
      Enum.member?(["a", "area"], elem) and not Microformats2.blank?(href) ->
        href

      Enum.member?(["img", "audio", "video", "source"], elem) and not Microformats2.blank?(src) ->
        src

      elem == "object" and not Microformats2.blank?(data) ->
        data

      elem == "video" and not Microformats2.blank?(poster) ->
        poster

      # TODO value-class-pattern at this position
      elem == "abbr" and not Microformats2.blank?(title) ->
        title

      Enum.member?(["data", "input"], elem) and not Microformats2.blank?(value) ->
        value

      true ->
        text_content(child) |> String.trim()
    end
    |> Microformats2.abs_uri(url, doc)
  end

  defp parse_prop("dt-" <> _, child = {elem, _, _}, _, _) do
    dt = Floki.attribute(child, "datetime")
    title = Floki.attribute(child, "title")
    value = Floki.attribute(child, "value")

    cond do
      Enum.member?(["time", "ins", "del"], elem) and not Microformats2.blank?(dt) ->
        dt |> List.first()

      elem == "abbr" and not Microformats2.blank?(title) ->
        title |> List.first()

      Enum.member?(["data", "input"], elem) and not Microformats2.blank?(value) ->
        value |> List.first()

      true ->
        text_content(child) |> String.trim()
    end
  end

  defp parse_prop("e-" <> _, child = {_, _, children}, _, _) do
    %{
      html: Microformats2.stripped_or_nil(Floki.raw_html(children)),
      text: Microformats2.stripped_or_nil(Floki.text(child))
    }
  end

  defp parse_prop(_, _, _, _), do: nil

  defp get_value(class, p) do
    cond do
      Microformats2.is_a?(class, "p") and p[:properties][:name] != nil ->
        List.first(p[:properties][:name])

      Microformats2.is_a?(class, "u") and p[:properties][:url] != nil ->
        List.first(p[:properties][:url])

      # and p[:properties][:url] != nil ->
      Microformats2.is_a?(class, "e") ->
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
          if Microformats2.is_rootlevel?(child) do
            Map.put(p, :value, get_value(class, p))
          else
            parse_prop(class, child, doc, url)
          end

        key = strip_prefix(class) |> to_key |> String.to_atom()
        val = if acc[key] != nil, do: acc[key], else: []
        Map.put(acc, key, val ++ [prop])
      end)

    if Microformats2.blank?(classes) and not Microformats2.blank?(p) and Microformats2.is_rootlevel?(child) do
      Map.put(item, :children, (item[:children] || []) ++ [p])
    else
      Map.put(item, :properties, props)
    end
  end

  defp strip_prefix("p-" <> rest) do
    rest
  end

  defp strip_prefix("u-" <> rest) do
    rest
  end

  defp strip_prefix("dt-" <> rest) do
    rest
  end

  defp strip_prefix("e-" <> rest) do
    rest
  end

  defp strip_prefix(rest) do
    rest
  end

  def text_content(child, text \\ "")

  def text_content(child = {elem, _, children}, text) do
    txt =
      if elem == "img" do
        alt = Floki.attribute(child, "alt")

        if !Microformats2.blank?(alt) do
          alt
        else
          Floki.attribute(child, "src")
        end
        |> List.first()
      else
        ""
      end

    Enum.reduce(children, text <> txt, fn child, acc ->
      text_content(child, acc)
    end)
  end

  def text_content(child, text) when is_bitstring(child) do
    text <> child
  end

  defp to_key(str) do
    String.replace(str, ~r/[-]/, "_")
  end
end
