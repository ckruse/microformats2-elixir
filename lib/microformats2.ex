defmodule Microformats2 do
  @moduledoc """
  A [microformats2](http://microformats.org/wiki/microformats2) parser for Elixir.
  """

  alias Microformats2.Helpers

  @doc """
  Parse a document either by URL or by content. Returns a microformats2 parsing structure or `:error`.

  ## Parameters

    * `content_or_url` is either the HTML document or a URL
    * `base_url_or_opts` is either the base URL of the document (if the first argument is a HTML string) or a
      keyword list of options
    * `opts` is an option list when the first argument is an HTML string

  ## Options

  Valid options are:

    * `:atomize_keys`: `true` or `false`, defaults to `false`. Convert keys to atoms when true, e.g. `"rels"` to `:rels`
    * `:underscore_keys`: `true` or `false`, `false` by default. Convert dashed keys to underscored keys when true,
      e.g. `"rel-urls"` to `"rel_urls"` or `:"rel-urls"` to `:rel_urls`

  ## Examples

      iex> Microformats2.parse("http://example.org/")
      %{"rels" => [], "rel-urls" => [], "items" => []}

      iex> Microformats2.parse("http://example.org/", atomize_keys: true, underscore_keys: true)
      %{rels: [], rel_urls: [], items: []}

      iex> Microformats2.parse(\"\"\"
      <div class="h-card">
        <img class="u-photo" alt="photo of Mitchell"
              src="https://webfwd.org/content/about-experts/300.mitchellbaker/mentor_mbaker.jpg"/>
        <a class="p-name u-url" href="http://blog.lizardwrangler.com/">Mitchell Baker</a>
        (<a class="u-url" href="https://twitter.com/MitchellBaker">@MitchellBaker</a>)
        <span class="p-org">Mozilla Foundation</span>
        <p class="p-note">
          Mitchell is responsible for setting the direction and scope of the Mozilla Foundation and its activities.
        </p>
        <span class="p-category">Strategy</span>
        <span class="p-category">Leadership</span>
      </div>
      \"\"\", "http://example.org")
      %{
        "items" => [
          %{
            "properties" => %{
              "category" => ["Strategy", "Leadership"],
              "name" => ["Mitchell Baker"],
              "note" => ["Mitchell is responsible for setting the direction and scope of the Mozilla Foundation and its activities."],
              "org" => ["Mozilla Foundation"],
              "photo" => [
                %{
                  "alt" => "photo of Mitchell",
                  "value" => "https://webfwd.org/content/about-experts/300.mitchellbaker/mentor_mbaker.jpg"
                }
              ],
              "url" => ["http://blog.lizardwrangler.com/",
               "https://twitter.com/MitchellBaker"]
            },
            "type" => ["h-card"]
          }
        ],
        "rel-urls" => %{},
        "rels" => %{}
      }

  """
  @spec parse(String.t() | Floki.html_tree(), String.t() | keyword(), keyword()) :: :error | map()
  def parse(content_or_url, base_url_or_opts \\ [], opts \\ [])

  if Code.ensure_loaded?(Tesla) do
    def parse(url, opts, _) when is_list(opts) do
      client = Tesla.client([{Tesla.Middleware.FollowRedirects, max_redirects: 3}])

      case Tesla.get(client, url) do
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

  defp escape_whitespaces(<<>>, new_content, _, _, _, _), do: new_content

  defp escape_whitespaces(<<cp::utf8, rest::binary>>, new_content, in_tag, in_attr, end_quote, in_special) do
    char = <<cp::utf8>>

    cond do
      # special tags: start
      char == "<" && in_tag == false && String.match?(rest, ~r/\A(style|script|svg)[\s>]/) ->
        escape_whitespaces(rest, new_content <> char, false, false, "", true)

      char == "<" && in_special && String.match?(rest, ~r/\A\/(style|script|svg)[\s>]/) ->
        escape_whitespaces(rest, new_content <> char, true, false, "", false)

      in_special ->
        escape_whitespaces(rest, new_content <> char, in_tag, in_attr, end_quote, in_special)

      char == end_quote && in_tag && in_attr ->
        escape_whitespaces(rest, new_content <> char, in_tag, false, "", in_special)

      char in ["\"", "'"] && in_tag && !in_attr ->
        escape_whitespaces(rest, new_content <> char, in_tag, true, char, in_special)

      char in ["<", ">"] && in_attr ->
        escape_whitespaces(rest, new_content <> char, in_tag, in_attr, end_quote, in_special)

      # tag ends
      char == ">" && in_tag == true && in_special == false ->
        escape_whitespaces(rest, new_content <> char, false, false, "", false)

      # tag starts
      char == "<" && in_tag == false ->
        escape_whitespaces(rest, new_content <> char, true, false, "", false)

      # whitespaces
      char == " " && in_tag == false ->
        escape_whitespaces(rest, new_content <> "&#32;", in_tag, in_attr, end_quote, in_special)

      char == "\n" && in_tag == false ->
        escape_whitespaces(rest, new_content <> "&#x0A;", in_tag, in_attr, end_quote, in_special)

      char == "\v" && in_tag == false ->
        escape_whitespaces(rest, new_content <> "&#x0B;", in_tag, in_attr, end_quote, in_special)

      char == "\r" && in_tag == false ->
        escape_whitespaces(rest, new_content <> "&#x0D;", in_tag, in_attr, end_quote, in_special)

      true ->
        escape_whitespaces(rest, new_content <> char, in_tag, in_attr, end_quote, in_special)
    end
  end

  # this is a really ugly hack, but html5ever doesn't support template tags (it fails with a nif_panic),
  # mochiweb has bugs with whitespaces and I can't really get fast_html to work
  defp parsed_document(content) do
    content
    |> escape_whitespaces("", false, false, "", false)
    |> Floki.parse_document()

    # |> IO.inspect()

    # |> normalize_tag_names()
  end
end
