defmodule Microformats2.Items.ImpliedProperties do
  import Microformats2.Helpers

  alias Microformats2.Items

  def parse(entry, root, url, doc) do
    entry
    |> implied_name_property(root)
    |> implied_photo_property(root)
    |> implied_url_property(root, url, doc)
  end

  defp implied_url_property(entry, root, doc_url, doc) do
    url_key = normalized_key("url")

    if entry[:properties][url_key] == nil do
      val = implied_url_attrval(root)

      url =
        if blank?(val) do
          implied_url_deep(root)
        else
          val
        end
        |> stripped_or_nil()

      if blank?(url),
        do: entry,
        else: put_in(entry, [:properties, url_key], [abs_uri(url, doc_url, doc)])
    else
      entry
    end
  end

  defp implied_photo_property(entry, root) do
    photo_key = normalized_key("photo")

    if entry[:properties][photo_key] == nil do
      val = implied_photo_attrval(root)

      url =
        if blank?(val) do
          implied_photo_deep(root)
        else
          val
        end
        |> stripped_or_nil()

      if blank?(url),
        do: entry,
        else: put_in(entry, [:properties, photo_key], [url])
    else
      entry
    end
  end

  defp implied_name_property(entry, root = {elem, _, _}) do
    name_key = normalized_key("name")

    if entry[:properties][name_key] == nil do
      nam =
        cond do
          elem == "img" or elem == "area" ->
            Floki.attribute(root, "alt") |> List.first()

          elem == "abbr" ->
            Floki.attribute(root, "title") |> List.first()

          true ->
            val = implied_name_deep(root)

            if blank?(val),
              do: Items.text_content(root),
              else: val
        end
        |> stripped_or_nil()

      put_in(entry, [:properties, name_key], [nam])
    else
      entry
    end
  end

  defp implied_name_deep({_, _, children}) do
    only_nodes = Enum.reject(children, &is_bitstring/1)

    if Enum.count(only_nodes) == 1 do
      sec_node = List.first(only_nodes)
      {_, _, sec_node_children} = sec_node
      attrval = implied_name_attrval(sec_node)

      if blank?(attrval) do
        sec_only_nodes = Enum.reject(sec_node_children, &is_bitstring/1)

        if Enum.count(sec_only_nodes) == 1 do
          third_node = sec_only_nodes |> List.first()
          implied_name_attrval(third_node)
        end
      else
        attrval
      end
    end
  end

  defp implied_name_attrval(node = {"img", _, _}), do: Floki.attribute(node, "alt") |> List.first()
  defp implied_name_attrval(node = {"area", _, _}), do: Floki.attribute(node, "alt") |> List.first()
  defp implied_name_attrval(node = {"abbr", _, _}), do: Floki.attribute(node, "title") |> List.first()
  defp implied_name_attrval(_), do: nil

  defp implied_photo_deep(root) do
    imgs = direct_not_h_children_with_attr(root, "img", "src")
    objects = direct_not_h_children_with_attr(root, "object", "data")

    cond do
      Enum.count(imgs) == 1 ->
        List.first(imgs) |> Floki.attribute("src") |> List.first()

      Enum.count(objects) == 1 ->
        List.first(objects) |> Floki.attribute("data") |> List.first()

      true ->
        {_, _, children} = root
        only_nodes = Enum.reject(children, &is_bitstring/1)

        if Enum.count(only_nodes) == 1 do
          child = List.first(only_nodes)
          sec_imgs = direct_not_h_children_with_attr(child, "img", "src")
          sec_objs = direct_not_h_children_with_attr(child, "object", "data")

          cond do
            Enum.count(sec_imgs) == 1 ->
              List.first(sec_imgs) |> Floki.attribute("src") |> List.first()

            Enum.count(sec_objs) == 1 ->
              List.first(sec_objs) |> Floki.attribute("data") |> List.first()

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
        List.first(as) |> Floki.attribute("href") |> List.first()

      Enum.count(areas) == 1 ->
        List.first(areas) |> Floki.attribute("href") |> List.first()

      true ->
        nil
    end
  end

  defp implied_photo_attrval(node = {"img", _, _}), do: Floki.attribute(node, "src") |> List.first()
  defp implied_photo_attrval(node = {"object", _, _}), do: Floki.attribute(node, "data") |> List.first()
  defp implied_photo_attrval(_), do: nil

  defp direct_not_h_children_with_attr({_, _, children}, name, attr) do
    Enum.filter(children, fn
      {el, _, _} -> el == name
      v when is_bitstring(v) -> false
    end)
    |> Enum.filter(fn el -> not is_rootlevel?(el) end)
    |> Enum.filter(fn el -> Enum.count(Floki.attribute(el, attr)) > 0 end)
  end

  defp implied_url_attrval(node = {"a", _, _}), do: Floki.attribute(node, "href") |> List.first()
  defp implied_url_attrval(node = {"area", _, _}), do: Floki.attribute(node, "href") |> List.first()
  defp implied_url_attrval(_), do: nil
end
