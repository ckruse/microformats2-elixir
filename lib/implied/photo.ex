defmodule Microformats2.Items.Implied.Photo do
  import Microformats2.Helpers

  alias Microformats2.Items

  def implied_value(root, doc_url, doc, opts) do
    val = implied_photo_attrval(root, doc_url, doc, opts)

    if blank?(val),
      do: implied_photo_deep(root, doc_url, doc, opts),
      else: val
  end

  defp implied_photo_deep(root, url, doc, opts) do
    imgs = direct_not_h_children_with_attr(root, "img", "src")
    objects = direct_not_h_children_with_attr(root, "object", "data")

    cond do
      Enum.count(imgs) == 1 ->
        Items.img_prop(List.first(imgs), url, doc, opts)

      Enum.count(objects) == 1 ->
        List.first(objects) |> Floki.attribute("data") |> List.first() |> abs_uri(url, doc)

      true ->
        {_, _, children} = root
        only_nodes = Enum.reject(children, &is_bitstring/1)

        if Enum.count(only_nodes) == 1 do
          child = List.first(only_nodes)
          sec_imgs = direct_not_h_children_with_attr(child, "img", "src")
          sec_objs = direct_not_h_children_with_attr(child, "object", "data")

          cond do
            Enum.count(sec_imgs) == 1 ->
              Items.img_prop(List.first(sec_imgs), url, doc, opts)

            Enum.count(sec_objs) == 1 ->
              List.first(sec_objs) |> Floki.attribute("data") |> List.first() |> abs_uri(url, doc)

            true ->
              nil
          end
        else
          nil
        end
    end
  end

  defp implied_photo_attrval(node = {"img", _, _}, url, doc, opts),
    do: Items.img_prop(node, url, doc, opts)

  defp implied_photo_attrval(node = {"object", _, _}, url, doc, _),
    do: Floki.attribute([node], "data") |> List.first() |> abs_uri(url, doc)

  defp implied_photo_attrval(_, _, _, _), do: nil

  defp direct_not_h_children_with_attr({_, _, children}, name, attr) do
    Enum.filter(children, fn
      {el, _, _} -> el == name
      v when is_bitstring(v) -> false
    end)
    |> Enum.filter(fn el -> not is_rootlevel?(el) end)
    |> Enum.filter(fn el -> Enum.count(Floki.attribute(el, attr)) > 0 end)
  end
end
