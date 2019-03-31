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

  def attr_list(node, attr \\ "class") do
    Floki.attribute(node, attr) |> List.first() |> to_string |> String.split(" ", trim: true)
  end

  def blank?(nil), do: true
  def blank?(""), do: true
  def blank?([]), do: true
  def blank?(_), do: false

  def stripped_or_nil(nil), do: nil
  def stripped_or_nil(val), do: String.trim(val)

  def is_rootlevel?(node) when is_tuple(node) do
    attr_list(node, "class")
    |> Enum.any?(fn cls -> is_a?(cls, "h") end)
  end

  def is_rootlevel?(class_name) when is_bitstring(class_name) do
    is_a?(class_name, "h")
  end

  def is_a?("h-" <> _, wanted), do: wanted == "h"
  def is_a?("p-" <> _, wanted), do: wanted == "p"
  def is_a?("e-" <> _, wanted), do: wanted == "e"
  def is_a?("u-" <> _, wanted), do: wanted == "u"
  def is_a?("dt-" <> _, wanted), do: wanted == "dt"
  def is_a?(_, _), do: false

  def has_a?(node, wanted) do
    attr_list(node) |> Enum.filter(fn class -> is_a?(class, wanted) end) |> blank?
  end

  def abs_uri(url, base_url, doc) do
    parsed = URI.parse(url)
    parsed_base = URI.parse(base_url)

    cond do
      # absolute URI
      not blank?(parsed.scheme) ->
        url

      # protocol relative URI
      blank?(parsed.scheme) and not blank?(parsed.host) ->
        URI.to_string(%{parsed | scheme: parsed_base.scheme})

      true ->
        base_element = Floki.find(doc, "base")

        new_base =
          if blank?(base_element) or blank?(Floki.attribute(base_element, "href")) do
            base_url
          else
            abs_uri(Floki.attribute(base_element, "href") |> List.first(), base_url, [])
          end

        parsed_new_base = URI.parse(new_base)
        new_path = Path.expand(parsed.path || "/", Path.dirname(parsed_new_base.path || "/"))

        URI.to_string(%{parsed | scheme: parsed_new_base.scheme, host: parsed_new_base.host, path: new_path})
    end
  end
end
