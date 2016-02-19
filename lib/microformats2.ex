
defmodule Microformats2 do
  def parse(content) when is_bitstring(content) do
    doc = Floki.parse(content) |> Floki.filter_out("template")
    rels = Microformats2.Rels.parse(doc)
    items = Microformats2.Items.parse(doc)

    %{items: items, rels: rels[:rels], rel_urls: rels[:rel_urls]}
  end

  def attr_list(node, attr \\ "class") do
    Floki.attribute(node, attr) |> List.first |> to_string |> String.split(" ", trim: true)
  end

  def blank?(nil), do: true
  def blank?(""), do: true
  def blank?([]), do: true
  def blank?(_), do: false

  def stripped_or_nil(nil), do: nil
  def stripped_or_nil(val), do: String.strip(val)

  def is_rootlevel?(node) when is_tuple(node) do
    attr_list(node, "class") |>
      Enum.any?(fn(cls) -> is_a?(cls, "h") end)
  end
  def is_rootlevel?(class_name) when is_bitstring(class_name) do
    is_a?(class_name, "h")
  end


  def is_a?("h-" <> _, wanted), do: wanted == "h"
  def is_a?("p-" <> _, wanted), do: wanted == "p"
  def is_a?("e-" <> _, wanted), do: wanted == "e"
  def is_a?("u-" <> _, wanted), do: wanted == "u"
  def is_a?("dt-" <> _, wanted), do: wanted == "dt"
  def is_a?(_, _), do: false
end
