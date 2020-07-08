defmodule Microformats2.Items.Implied do
  import Microformats2.Helpers

  alias Microformats2.Items.Implied

  def parse({entry, _}, root, url, doc, opts) do
    entry
    |> implied_name_property(root, opts)
    |> implied_photo_property(root, url, doc, opts)
    |> implied_url_property(root, url, doc, opts)
  end

  defp implied_url_property(entry, root, doc_url, doc, opts) do
    with true <- should_imply?(entry, root, opts, :url),
         url <- Implied.Url.implied_value(root),
         false <- is_nil(url) do
      put_in(entry, [normalized_key("properties", opts), normalized_key("url", opts)], [abs_uri(url, doc_url, doc)])
    else
      _ -> entry
    end
  end

  defp implied_photo_property(entry, root, doc_url, doc, opts) do
    with true <- should_imply?(entry, root, opts, :photo),
         url <- Implied.Photo.implied_value(root, doc_url, doc, opts),
         true <- present?(url) do
      put_in(entry, [normalized_key("properties", opts), normalized_key("photo", opts)], [url])
    else
      _ -> entry
    end
  end

  defp implied_name_property(entry, root, opts) do
    with true <- should_imply?(entry, root, opts, :name),
         nam <- Implied.Name.implied_value(root),
         present?(nam) do
      put_in(entry, [normalized_key("properties", opts), normalized_key("name", opts)], [nam])
    else
      _ -> entry
    end
  end

  defp should_imply?(entry, {_, _, children}, opts, :url) do
    {_, acc} =
      Floki.traverse_and_update(children, 0, fn node, acc ->
        if has_a?(node, "u"),
          do: {node, acc + 1},
          else: {node, acc}
      end)

    !has_nested?(children) && entry[normalized_key("properties", opts)][normalized_key("url", opts)] == nil && acc == 0
  end

  defp should_imply?(entry, {_, _, children}, opts, :name) do
    {_, acc} =
      Floki.traverse_and_update(children, 0, fn node, acc ->
        if has_a?(node, "p") || has_a?(node, "e"),
          do: {node, acc + 1},
          else: {node, acc}
      end)

    !has_nested?(children) && entry[normalized_key("properties", opts)][normalized_key("name", opts)] == nil &&
      blank?(entry[normalized_key("children", opts)]) && acc == 0
  end

  defp should_imply?(entry, {_, _, children}, opts, :photo) do
    {_, acc} =
      Floki.traverse_and_update(children, 0, fn node, acc ->
        if has_a?(node, "u"),
          do: {node, acc + 1},
          else: {node, acc}
      end)

    !has_nested?(children) && entry[normalized_key("properties", opts)][normalized_key("photo", opts)] == nil &&
      acc == 0
  end
end
