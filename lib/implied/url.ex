defmodule Microformats2.Items.Implied.Url do
  @moduledoc false
  import Microformats2.Helpers

  def implied_value(root) do
    cond do
      href = href_if_is_a_area_and_has_href(root) -> href
      href = href_if_direct_child_only_type(root, "a") -> href
      href = href_if_direct_child_only_type(root, "area") -> href
      href = intermediate_only_child(root, "a") -> href
      href = intermediate_only_child(root, "area") -> href
      true -> nil
    end
  end

  defp href_if_is_a_area_and_has_href(node) do
    {elem, _, _} = node
    href = Floki.attribute([node], "href") |> List.first()

    if elem in ["a", "area"] && !is_nil(href),
      do: href,
      else: nil
  end

  # .h-x>a[href]:only-of-type:not[.h-*]
  # .h-x>area[href]:only-of-type:not[.h-*]
  defp href_if_direct_child_only_type(node, elem) do
    with [elem_node] <- Floki.find([node], ">#{elem}[href]"),
         false <- is_a?(elem_node, "h") do
      Floki.attribute([elem_node], "href") |> List.first()
    else
      _ -> nil
    end
  end

  # .h-x>:only-child:not[.h-*]>a[href]:only-of-type:not[.h-*]
  # .h-x>:only-child:not[.h-*]>area[href]:only-of-type:not[.h-*]
  defp intermediate_only_child(node, elem) do
    case node do
      {_, _, [only_child]} -> href_if_direct_child_only_type(only_child, elem)
      _ -> nil
    end
  end
end
