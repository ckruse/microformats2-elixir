defmodule Microformats2.Items.DtProp do
  import Microformats2.Helpers

  def parsed_prop(child = {elem, _, _}) do
    dt = Floki.attribute([child], "datetime")
    title = Floki.attribute([child], "title")
    value = Floki.attribute([child], "value")

    cond do
      Enum.member?(["time", "ins", "del"], elem) and present?(dt) ->
        dt |> List.first()

      elem == "abbr" and present?(title) ->
        title |> List.first()

      Enum.member?(["data", "input"], elem) and present?(value) ->
        value |> List.first()

      true ->
        text_content(child) |> String.trim()
    end
  end
end
