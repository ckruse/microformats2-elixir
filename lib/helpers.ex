defmodule Microformats2.Helpers do
  @spec attr_list(String.t() | Floki.html_tree(), String.t()) :: [String.t()]
  def attr_list(node, attr \\ "class")

  def attr_list(node, attr) when is_list(node) do
    node
    |> Enum.reject(&is_bitstring/1)
    |> Enum.flat_map(&attr_list(&1, attr))
    |> Enum.uniq()
  end

  def attr_list(node, attr) do
    node
    |> Floki.attribute(attr)
    |> List.first()
    |> to_string
    |> String.split(" ", trim: true)
  end

  @spec blank?(any()) :: boolean()
  def blank?(nil), do: true
  def blank?(""), do: true
  def blank?([]), do: true
  def blank?(_), do: false

  @spec present?(any()) :: boolean()
  def present?(v), do: not blank?(v)

  @spec stripped_or_nil(nil | String.t()) :: nil | String.t()
  def stripped_or_nil(nil), do: nil
  def stripped_or_nil(val), do: String.trim(val)

  @spec is_rootlevel?(bitstring() | tuple()) :: boolean()
  def is_rootlevel?(node) when is_tuple(node) do
    [node]
    |> attr_list("class")
    |> Enum.any?(&is_a?(&1, "h"))
  end

  def is_rootlevel?(class_name) when is_bitstring(class_name) do
    is_a?(class_name, "h")
  end

  @spec is_a?(any(), any()) :: boolean()
  def is_a?("h-" <> _ = type, wanted), do: wanted == "h" && valid_mf2_name?(type)
  def is_a?("p-" <> _ = type, wanted), do: wanted == "p" && valid_mf2_name?(type)
  def is_a?("e-" <> _ = type, wanted), do: wanted == "e" && valid_mf2_name?(type)
  def is_a?("u-" <> _ = type, wanted), do: wanted == "u" && valid_mf2_name?(type)
  def is_a?("dt-" <> _ = type, wanted), do: wanted == "dt" && valid_mf2_name?(type)
  def is_a?(_, _), do: false

  @spec has_a?(String.t() | Floki.html_tree(), any()) :: boolean()
  def has_a?(node, wanted) do
    node
    |> attr_list()
    |> Enum.filter(&is_a?(&1, wanted))
    |> present?()
  end

  defp find_base(url, doc) do
    base_element = Floki.find(doc, "base")

    if blank?(base_element) || blank?(Floki.attribute(base_element, "href")) do
      URI.parse(url)
    else
      base_element
      |> Floki.attribute("href")
      |> List.first()
      |> abs_uri(url, [])
      |> URI.parse()
    end
  end

  @spec abs_uri(String.t(), String.t(), any()) :: String.t()
  def abs_uri(url, base_url, doc) do
    parsed = URI.parse(url)
    parsed_base = find_base(base_url, doc)

    cond do
      # absolute URI
      present?(parsed.scheme) ->
        url

      # protocol relative URI
      blank?(parsed.scheme) && present?(parsed.authority) ->
        URI.to_string(%{parsed | scheme: parsed_base.scheme})

      true ->
        new_path =
          (parsed.path || "")
          |> Path.expand(parsed_base.path || "/")
          |> maybe_append_slash(parsed.path || "")

        URI.to_string(%{parsed | scheme: parsed_base.scheme, authority: parsed_base.authority, path: new_path})
    end
  end

  defp maybe_append_slash(new_path, old_path) do
    if String.ends_with?(old_path, "/") && !String.ends_with?(new_path, "/"),
      do: "#{new_path}/",
      else: new_path
  end

  @spec normalized_key(String.t(), keyword()) :: String.t() | atom()
  def normalized_key(key, opts) do
    norm_key =
      if Keyword.get(opts, :underscore_keys, true),
        do: String.replace(key, "-", "_"),
        else: key

    if Keyword.get(opts, :atomize_keys, true),
      do: String.to_atom(norm_key),
      else: norm_key
  end

  @spec valid_mf2_name?(String.t()) :: boolean()
  def valid_mf2_name?(name), do: name =~ ~r/^(?:h|p|e|u|dt)(?:-[a-z0-9]+)?(?:-[a-z]+)+$/

  @spec non_h_type?(String.t()) :: boolean()
  def non_h_type?("p-" <> _ = type), do: valid_mf2_name?(type)
  def non_h_type?("u-" <> _ = type), do: valid_mf2_name?(type)
  def non_h_type?("dt-" <> _ = type), do: valid_mf2_name?(type)
  def non_h_type?("e-" <> _ = type), do: valid_mf2_name?(type)
  def non_h_type?(_), do: false

  def has_nested?(root) do
    {_, acc} =
      Floki.traverse_and_update(root, 0, fn node, acc ->
        if has_a?(node, "h"),
          do: {node, acc + 1},
          else: {node, acc}
      end)

    acc > 0
  end

  def cleanup_html(node) do
    node
    |> Floki.filter_out("style")
    |> Floki.filter_out("script")
  end

  def text_content(tree, image_replacer \\ nil),
    do: text_content(tree, nil, nil, image_replacer)

  def text_content(tree, doc, doc_url, image_replacer \\ nil)

  def text_content(tree, doc, doc_url, image_replacer) when not is_list(tree),
    do: text_content([tree], doc, doc_url, image_replacer)

  def text_content(tree, doc, doc_url, image_replacer) do
    Floki.traverse_and_update(tree, fn
      {"img", _, _} = node ->
        if image_replacer,
          do: image_replacer.(node, doc_url, doc),
          else: node

      node ->
        node
    end)
    |> Floki.text()
  end

  def replaced_img_by_alt_or_src(img, doc_url, doc) do
    alt = Floki.attribute([img], "alt") |> List.first()
    src = Floki.attribute([img], "src") |> List.first()

    cond do
      !is_nil(alt) ->
        alt

      !is_nil(src) ->
        " " <> abs_uri(src, doc_url, doc) <> " "

      true ->
        nil
    end
  end

  def replaced_img_by_alt_only(img, _, _) do
    alt = Floki.attribute([img], "alt") |> List.first()

    if !is_nil(alt),
      do: alt,
      else: nil
  end
end
