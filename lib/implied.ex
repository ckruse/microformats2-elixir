defmodule Microformats2.Items.ImpliedProperties do
  def parse(entry, root) do
    implied_name_property(entry, root) |>
      implied_photo_property(root) |>
      implied_url_property(root)
  end

  defp implied_url_property(entry, root) do
    if entry[:properties][:root] == nil do
      val = implied_url_attrval(root)

      url = if Microformats2.blank?(val) do
        implied_url_deep(root)
      else
        val
      end |> Microformats2.stripped_or_nil

      if Microformats2.blank?(url) do
        entry
      else
        Map.put(entry, :properties, Map.put(entry[:properties], :url, [url]))
      end
    else
      entry
    end
  end

  defp implied_photo_property(entry, root) do
    if entry[:properties][:photo] == nil do
      val = implied_photo_attrval(root)

      url = if Microformats2.blank?(val) do
        implied_photo_deep(root)
      else
        val
      end |> Microformats2.stripped_or_nil

      if Microformats2.blank?(url) do
        entry
      else
        Map.put(entry, :properties, Map.put(entry[:properties], :photo, [url]))
      end
    else
      entry
    end
  end


  defp implied_name_property(entry, root = {elem, _, _}) do
    if entry[:properties][:name] == nil do
      nam = cond do
        elem == "img" or elem == "area" ->
          Floki.attribute(root, "alt") |> List.first
        elem == "abbr" ->
          Floki.attribute(root, "title") |> List.first
        true ->
          val = implied_name_deep(root)

          if Microformats2.blank?(val) do
            Microformats2.Items.text_content(root)
          else
            val
          end

      end |> Microformats2.stripped_or_nil

      Map.put(entry, :properties, Map.put(entry[:properties], :name, [nam]))
    else
      entry
    end
  end

  defp implied_name_deep({_, _, children}) do
    only_nodes = Enum.filter(children,
      fn(el) when is_bitstring(el) -> false
        (_) -> true end)

    if Enum.count(only_nodes) == 1 do
      sec_node = List.first(only_nodes)
      {_, _, sec_node_children} = sec_node
      attrval = implied_name_attrval(sec_node)

      if Microformats2.blank?(attrval) do
        sec_only_nodes = Enum.filter(sec_node_children,
          fn(el) when is_bitstring(el) -> false
            (_) -> true end)

        if Enum.count(sec_only_nodes) == 1 do
          third_node = sec_only_nodes |> List.first
          implied_name_attrval(third_node)
        end
      else
        attrval
      end
    end
  end

  defp implied_name_attrval(node = {"img", _, _}) do
    Floki.attribute(node, "alt") |> List.first
  end
  defp implied_name_attrval(node = {"area", _, _}) do
    Floki.attribute(node, "alt") |> List.first
  end
  defp implied_name_attrval(node = {"abbr", _, _}) do
    Floki.attribute(node, "title") |> List.first
  end
  defp implied_name_attrval(_) do
    nil
  end



  defp implied_photo_deep(root) do
    imgs = direct_not_h_children_with_attr(root, "img", "src")
    objects = direct_not_h_children_with_attr(root, "object", "data")

    cond do
      Enum.count(imgs) == 1 ->
        List.first(imgs) |> Floki.attribute("src") |> List.first
      Enum.count(objects) == 1 ->
        List.first(objects) |> Floki.attribute("data") |> List.first

      true ->
        {_, _, children} = root
        only_nodes = Enum.filter(children,
          fn(el) when is_bitstring(el) -> false
            (_) -> true end)

        if Enum.count(children) == 1 do
          child = List.first(children)
          sec_imgs = direct_not_h_children_with_attr(root, "img", "src")
          sec_objs = direct_not_h_children_with_attr(root, "object", "data")

          cond do
            Enum.count(sec_imgs) == 1 ->
              List.first(sec_imgs) |> Floki.attribute("src") |> List.first
            Enum.count(sec_objs) == 1 ->
              List.first(sec_objs) |> Floki.attribute("data") |> List.first
            true ->
              nil
          end
        else
          nil
        end
    end
  end

  defp implied_url_deep(root) do
    as = direct_not_h_children_with_attr(root, "a", "href")
    areas = direct_not_h_children_with_attr(root, "area", "href")

    cond do
      Enum.count(as) == 1 ->
        List.first(as) |> Floki.attribute("href") |> List.first
      Enum.count(areas) == 1 ->
        List.first(areas) |> Floki.attribute("href") |> List.first
      true ->
        nil
    end
  end


  defp implied_photo_attrval(node = {"img", _, _}) do
    Floki.attribute(node, "src") |> List.first
  end
  defp implied_photo_attrval(node = {"object", _, _}) do
    Floki.attribute(node, "data") |> List.first
  end
  defp implied_photo_attrval(_) do
    nil
  end

  defp direct_not_h_children_with_attr({_, _, children}, name, attr) do
    Enum.filter(children,
      fn({el, _, _}) -> el == name
        (v) when is_bitstring(v) -> false
      end) |>
      Enum.filter(fn(el) -> not Microformats2.is_rootlevel?(el) end) |>
      Enum.filter(fn(el) -> Enum.count(Floki.attribute(el, attr)) > 0 end)
  end

  defp implied_url_attrval(node = {"a", _, _}) do
    Floki.attribute(node, "href") |> List.first
  end
  defp implied_url_attrval(node = {"area", _, _}) do
    Floki.attribute(node, "href") |> List.first
  end
  defp implied_url_attrval(_) do
    nil
  end
end
