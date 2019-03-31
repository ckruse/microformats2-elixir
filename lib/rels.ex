defmodule Microformats2.Rels do
  import Microformats2.Helpers

  def parse(doc, base_url) do
    link_rels =
      Floki.find(doc, "[rel][href]")
      |> Enum.filter(fn element ->
        rel = Floki.attribute(element, "rel") |> List.first()
        href = Floki.attribute(element, "href") |> List.first()

        String.trim(to_string(rel)) != "" and String.trim(to_string(href)) != ""
      end)
      |> Enum.reduce(%{rels: %{}, rel_urls: %{}}, fn element, acc ->
        rel = attr_list(element, "rel")
        url = Floki.attribute(element, "href") |> List.first() |> abs_uri(base_url, doc)

        acc
        |> save_urls_by_rels(rel, url)
        |> save_rels_by_urls(rel, url)
        |> save_attributes(element, url)
      end)

    link_rels
  end

  defp save_urls_by_rels(map, rel, url) do
    Enum.reduce(rel, map, fn rel, nmap ->
      if nmap[:rels][rel] == nil,
        do: put_in(nmap, [:rels, rel], [url]),
        else: put_in(nmap, [:rels, rel], Enum.uniq(nmap[:rels][rel] ++ [url]))
    end)
  end

  defp save_rels_by_urls(map, rel, url) do
    if map[:rel_urls][url] == nil,
      do: put_in(map, [:rel_urls, url], %{rels: rel}),
      else: put_in(map, [:rel_urls, url, :rels], Enum.uniq(map[:rel_urls][url][:rels] ++ rel))
  end

  defp save_text(map, element, url) do
    text = Floki.text(element)

    if String.trim(to_string(text)) == "" or map[:rel_urls][url][:text] != nil,
      do: map,
      else: put_in(map, [:rel_urls, url, :text], text)
  end

  defp save_attributes(map, element, url) do
    Enum.reduce(["hreflang", "media", "title", "type"], save_text(map, element, url), fn att, nmap ->
      val = Floki.attribute(element, att) |> List.first()
      key = String.to_atom(att)

      if String.trim(to_string(val)) == "" or nmap[:rel_urls][url][key] != nil,
        do: nmap,
        else: put_in(nmap, [:rel_urls, url, key], val)
    end)
  end
end
