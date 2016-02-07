defmodule Microformats2 do
  def parse(content) when is_bitstring(content) do
    doc = Floki.parse(content) |> Floki.filter_out("template")
    rels = Microformats2.Rels.parse(doc)

    %{items: [], rels: rels[:rels], rel_urls: rels[:rel_urls]}
  end


end
