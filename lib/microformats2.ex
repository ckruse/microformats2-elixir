
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
end
