defmodule Microformats2.Rels do
  import Microformats2.Helpers

  def parse(doc, base_url, opts) do
    link_rels =
      Floki.find(doc, "[rel][href]")
      |> Enum.filter(fn element ->
        rel = Floki.attribute(element, "rel") |> List.first()
        href = Floki.attribute(element, "href") |> List.first()

        String.trim(to_string(rel)) != "" and String.trim(to_string(href)) != ""
      end)
      |> Enum.reduce(%{normalized_key("rels", opts) => %{}, normalized_key("rel_urls", opts) => %{}}, fn element, acc ->
        rel = attr_list(element, "rel")
        url = Floki.attribute(element, "href") |> List.first() |> abs_uri(base_url, doc)

        acc
        |> save_urls_by_rels(rel, url, opts)
        |> save_rels_by_urls(rel, url, opts)
        |> save_attributes(element, url, opts)
      end)

    link_rels
  end

  defp save_urls_by_rels(map, rel, url, opts) do
    Enum.reduce(rel, map, fn rel, nmap ->
      key = normalized_key(rel, opts)

      if nmap[normalized_key("rels", opts)][key] == nil do
        put_in(nmap, [normalized_key("rels", opts), key], [url])
      else
        put_in(nmap, [normalized_key("rels", opts), key], Enum.uniq(nmap[normalized_key("rels", opts)][key] ++ [url]))
      end
    end)
  end

  defp save_rels_by_urls(map, rel, url, opts) do
    if map[normalized_key("rel_urls", opts)][url] == nil do
      put_in(map, [normalized_key("rel_urls", opts), url], %{normalized_key("rels", opts) => rel})
    else
      put_in(
        map,
        [normalized_key("rel_urls", opts), url, normalized_key("rels", opts)],
        Enum.uniq(map[normalized_key("rel_urls", opts)][url][normalized_key("rels", opts)] ++ rel)
      )
    end
  end

  defp save_text(map, element, url, opts) do
    text = Floki.text(element)

    if String.trim(to_string(text)) == "" or
         map[normalized_key("rel_urls", opts)][url][normalized_key("text", opts)] != nil,
       do: map,
       else: put_in(map, [normalized_key("rel_urls", opts), url, normalized_key("text", opts)], text)
  end

  defp save_attributes(map, element, url, opts) do
    Enum.reduce(["hreflang", "media", "title", "type"], save_text(map, element, url, opts), fn att, nmap ->
      val = Floki.attribute(element, att) |> List.first()
      key = normalized_key(att, opts)

      if String.trim(to_string(val)) == "" or nmap[normalized_key("rel_urls", opts)][url][key] != nil,
        do: nmap,
        else: put_in(nmap, [normalized_key("rel_urls", opts), url, key], val)
    end)
  end
end
