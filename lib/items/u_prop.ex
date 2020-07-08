defmodule Microformats2.Items.UProp do
  @moduledoc false
  import Microformats2.Helpers
  alias Microformats2.Items

  def parsed_prop(child = {elem, _, _}, doc, url, opts, state) do
    href = Floki.attribute([child], "href") |> List.first()
    src = Floki.attribute([child], "src") |> List.first()
    data = Floki.attribute([child], "data") |> List.first()
    poster = Floki.attribute([child], "poster") |> List.first()
    title = Floki.attribute([child], "title") |> List.first()
    value = Floki.attribute([child], "value") |> List.first()

    retval =
      cond do
        elem in ~w[a area link] && !is_nil(href) ->
          abs_uri(href, url, doc)

        elem == "img" && !is_nil(src) ->
          Items.img_prop(child, url, doc, opts)

        elem in ~w[audio video source iframe] && !is_nil(src) ->
          abs_uri(src, url, doc)

        elem == "video" && !is_nil(poster) ->
          abs_uri(poster, url, doc)

        elem == "object" && !is_nil(data) ->
          abs_uri(data, url, doc)

        v = Items.Value.parse_value_class([child]) ->
          abs_uri(v, url, doc)

        elem == "abbr" && !is_nil(title) ->
          abs_uri(title, url, doc)

        elem in ~w[data input] && !is_nil(value) ->
          abs_uri(value, url, doc)

        true ->
          text_content(child) |> String.trim() |> abs_uri(url, doc)
      end

    {retval, state}
  end
end
