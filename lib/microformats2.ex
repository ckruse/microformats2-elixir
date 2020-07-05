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
    case parsed_document(content) do
      {:ok, doc} -> parse(doc, url, opts)
      _ -> :error
    end
  end

  def parse(content, url, opts) do
    doc =
      content
      |> Floki.filter_out("template")
      |> Floki.filter_out(:comment)

    rels = Microformats2.Rels.parse(doc, url, opts)
    items = Microformats2.Items.parse(doc, doc, url, opts)

    %{
      Helpers.normalized_key("items", opts) => items,
      Helpers.normalized_key("rels", opts) => rels[Helpers.normalized_key("rels", opts)],
      Helpers.normalized_key("rel-urls", opts) => rels[Helpers.normalized_key("rel-urls", opts)]
    }
  end

  defp replace_whitespaces(text, last_text \\ "")
  defp replace_whitespaces(text, last_text) when last_text == text, do: text

  defp replace_whitespaces(text, _) do
    text
    |> String.replace(~r/>((&#32;)*) ( *)</, ">\\g{1}&#32;\\g{3}<")
    |> replace_whitespaces(text)
  end

  # this is a really ugly hack, but html5ever doesn't support template tags (it fails with a nif_panic),
  # mochiweb has bugs whith whitespaces and I can't really get fast_html to work
  defp parsed_document(content) do
    content
    |> replace_whitespaces()
    |> String.replace(~r/\015/, "&#x0D;")
    |> String.replace(~r/\012/, "&#x0A;")
    |> String.replace(~r/\013/, "&#x0B;")
    |> Floki.parse_document()
  end
end
