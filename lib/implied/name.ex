defmodule Microformats2.Items.Implied.Name do
  @moduledoc false
  import Microformats2.Helpers

  def implied_value(root = {elem, _, _}) do
    cond do
      elem == "img" or elem == "area" ->
        Floki.attribute([root], "alt") |> List.first()

      elem == "abbr" ->
        Floki.attribute([root], "title") |> List.first()

      true ->
        val = implied_name_deep(root)

        if blank?(val),
          do: [root] |> cleanup_html() |> text_content(&replaced_img_by_alt_only/3),
          else: val
    end
    |> stripped_or_nil()
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

  defp implied_name_attrval(node = {"img", _, _}), do: Floki.attribute([node], "alt") |> List.first()
  defp implied_name_attrval(node = {"area", _, _}), do: Floki.attribute([node], "alt") |> List.first()
  defp implied_name_attrval(node = {"abbr", _, _}), do: Floki.attribute([node], "title") |> List.first()
  defp implied_name_attrval(_), do: nil
end
