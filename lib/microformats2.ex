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

        acc |>
          save_urls_by_rels(rel, url) |>
          save_rels_by_urls(rel, url)
      end)

    link_rels
  end

  defp save_urls_by_rels(map, rel, url) do
    Enum.reduce(rel, map, fn(rel, nmap) ->
      if nmap[:rels][rel] == nil do
        Map.put(nmap, :rels,
                Map.put(nmap[:rels], rel, [url]))
      else
        Map.put(nmap, :rels,
                Map.put(nmap[:rels], rel,
                        Enum.uniq(nmap[:rels][rel] ++ [url])))
      end
    end)
  end

  defp save_rels_by_urls(map, rel, url) do
    if map[:rel_urls][url] == nil do
      Map.put(map, :rel_urls,
              Map.put(map[:rel_urls], url, %{rels: rel}))
    else
      Map.put(map, :rel_urls,
              Map.put(map[:rel_urls], url,
                      %{rels: Enum.uniq(map[:rel_urls][url][:rels] ++ rel)}))
    end
  end
end
