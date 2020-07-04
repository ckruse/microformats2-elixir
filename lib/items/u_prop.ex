defmodule Microformats2.Items.UProp do
  import Microformats2.Helpers
  alias Microformats2.Items

  def parsed_prop(child = {elem, _, _}, doc, url, opts) do
    href = Floki.attribute([child], "href") |> List.first()
    src = Floki.attribute([child], "src") |> List.first()
    data = Floki.attribute([child], "data") |> List.first()
    poster = Floki.attribute([child], "poster") |> List.first()
    title = Floki.attribute([child], "title") |> List.first()
    value = Floki.attribute([child], "value") |> List.first()

    cond do
      Enum.member?(["a", "area"], elem) && !is_nil(href) ->
        abs_uri(href, url, doc)

      elem == "img" && present?(src) ->
        Items.img_prop(child, url, doc, opts)

      Enum.member?(["img", "audio", "video", "source"], elem) && present?(src) ->
        abs_uri(src, url, doc)

      elem == "object" && present?(data) ->
        data

      elem == "video" && present?(poster) ->
        poster

      # TODO value-class-pattern at this position
      elem == "abbr" && present?(title) ->
        title

      Enum.member?(["data", "input"], elem) && present?(value) ->
        value

      true ->
        text_content(child) |> String.trim() |> abs_uri(url, doc)
    end
  end
end
