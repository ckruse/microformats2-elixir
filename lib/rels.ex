defmodule Microformats2.Rels do
  def parse(doc) do
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
          save_rels_by_urls(rel, url) |>
          save_attributes(element, url)
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
                      Map.put(map[:rel_urls][url], :rels, Enum.uniq(map[:rel_urls][url][:rels] ++ rel))))
    end
  end

  defp save_text(map, element, url) do
    text = Floki.text(element)

    if String.strip(to_string(text)) == "" or map[:rel_urls][url][:text] != nil do
      map
    else
      Map.put(map, :rel_urls,
              Map.put(map[:rel_urls], url,
                      Map.put(map[:rel_urls][url], :text, text)))
    end
  end

  defp save_attributes(map, element, url) do
    Enum.reduce(["hreflang", "media", "title", "type"],
                save_text(map, element, url),
      fn(att, nmap) ->
        val = Floki.attribute(element, att) |> List.first

        if String.strip(to_string(val)) == "" or nmap[:rel_urls][url][String.to_atom(att)] != nil do
          nmap
        else
          Map.put(nmap, :rel_urls,
                  Map.put(nmap[:rel_urls], url,
                          Map.put(nmap[:rel_urls][url], String.to_atom(att), val)))
        end
      end)
  end
end
