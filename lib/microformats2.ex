defmodule Microformats2 do
  alias Microformats2.Helpers

  if Code.ensure_loaded?(Tesla) do
    use Tesla
    plug(Tesla.Middleware.FollowRedirects, max_redirects: 3)

    @type t :: map()

    @spec parse(String.t() | Floki.html_tree(), String.t() | keyword(), keyword()) :: :error | t()
    def parse(content_or_url, base_url_or_opts \\ [], opts \\ [])

    def parse(url, opts, _) when is_list(opts) do
      case get(url) do
        {:ok, response} -> parse(response.body, url, opts)
        _ -> :error
      end
    end
  end

  def parse(content, url, opts) when is_binary(content) do
    case Floki.parse_document(content) do
      {:ok, doc} -> parse(doc, url, opts)
      _ -> :error
    end
  end

  def parse(content, url, opts) do
    doc =
      content
      |> Floki.filter_out("template")
      |> Floki.filter_out("style")
      |> Floki.filter_out("script")
      |> Floki.filter_out(:comment)

    rels = Microformats2.Rels.parse(doc, url, opts)
    items = Microformats2.Items.parse(doc, doc, url, opts)

    %{
      Helpers.normalized_key("items", opts) => items,
      Helpers.normalized_key("rels", opts) => rels[Helpers.normalized_key("rels", opts)],
      Helpers.normalized_key("rel-urls", opts) => rels[Helpers.normalized_key("rel-urls", opts)]
    }
  end
end
