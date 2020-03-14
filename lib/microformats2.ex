defmodule Microformats2 do
  if Code.ensure_loaded?(Tesla) do
    plug Tesla.Middleware.FollowRedirects, max_redirects: 3 # defaults to 5
    def parse(url) do
      {status, response} = Tesla.get(url)
      case status do
        :ok -> parse(response.body, url)
        _ -> :error
      end
    end
  end

  def parse(content, url) when is_binary(content), do: parse(Floki.parse(content), url)

  def parse(content, url) do
    doc =
      content
      |> Floki.filter_out("template")
      |> Floki.filter_out("style")
      |> Floki.filter_out("script")
      |> Floki.filter_out(:comment)

    rels = Microformats2.Rels.parse(doc, url)
    items = Microformats2.Items.parse(doc, doc, url)

    %{items: items, rels: rels[:rels], rel_urls: rels[:rel_urls]}
  end
end
