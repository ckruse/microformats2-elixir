defmodule Microformats2 do
  def parse(url) do
    response = HTTPotion.get(url, follow_redirects: true)

    if HTTPotion.Response.success?(response) do
      parse(response.body, url)
    else
      :error
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
