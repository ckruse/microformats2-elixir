defmodule Microformats2 do
  def parse(content) when is_bitstring(content) do
    doc = Floki.parse(content)
    rels = parse_rels(doc)

    %{items: [], rels: rels[:rels], rel_urls: rels[:rel_urls]}
  end

  defp parse_rels(doc) do
    link_rels = Floki.find(doc, "[rel][href]") |>
      Enum.filter(fn(element) ->
        rel = Floki.attribute(element, "rel") |> List.first
        href = Floki.attribute(element, "href") |> List.first
        String.strip(to_string(rel)) != "" and String.strip(to_string(href)) != ""
      end) |>
      Enum.reduce(%{rels: %{}, rel_urls: %{}}, fn(element, acc) ->
        rel = Floki.attribute(element, "rel") |> List.first |> String.split(" ", trim: true)
        url = Floki.attribute(element, "href") |> List.first # TODO convert to absolute URL

        n_map = Enum.reduce(rel, acc, fn(rel, map) ->
          if map[:rels][rel] == nil do
            Map.put(map, :rels, Map.put(map[:rels], rel, [url]))
          else
            Map.put(map, :rels, Map.put(map[:rels], rel, Enum.uniq(map[:rels][rel] ++ [url])))
          end
        end)

        if n_map[:rel_urls][url] == nil do
          Map.put(n_map, :rel_urls, Map.put(n_map[:rel_urls], url, rel))
        else
          Map.put(n_map, :rel_urls, Map.put(n_map[:rel_urls], url, Enum.uniq(n_map[:rel_urls][url] ++ rel)))
        end
      end)

    link_rels
  end
end
