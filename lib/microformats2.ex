defmodule Microformats2 do
  if Code.ensure_loaded?(Tesla) do
    use Tesla
    plug(Tesla.Middleware.FollowRedirects, max_redirects: 3)

    def parse(url) do
      case get(url) do
        {:ok, response} -> parse(response.body, url)
        _ -> :error
      end
    end
  end
  import Microformats2.Helpers, only: [normalized_key: 1]

  def parse(content, url) when is_binary(content) do
    case Floki.parse_document(content) do
      {:ok, doc} -> parse(doc, url)
      _ -> :error
    end
  end

  def parse(content, url) do
    doc =
      content
      |> Floki.filter_out("template")
      |> Floki.filter_out("style")
      |> Floki.filter_out("script")
      |> Floki.filter_out(:comment)

    rels = Microformats2.Rels.parse(doc, url)
    items = Microformats2.Items.parse(doc, doc, url)

    Map.new
    |> Map.put(normalized_key("items"), items)
    |> Map.put(normalized_key("rels"), rels[normalized_key("rels")])
    |> Map.put(normalized_key("rel_urls"), rels[normalized_key("rel_urls")])
  end
end
