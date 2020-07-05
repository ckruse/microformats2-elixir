defmodule Microformats2.Items.PProp do
  import Microformats2.Helpers

  def parsed_prop(child, doc, doc_url) do
    {elem, _, _} = child
    title = Floki.attribute([child], "title") |> List.first()
    alt = Floki.attribute([child], "alt") |> List.first()
    value = Floki.attribute([child], "value") |> List.first()

    cond do
      elem in ["abbr", "link"] && present?(title) -> title
      elem in ["data", "input"] && present?(value) -> value
      elem in ["img", "area"] && present?(alt) -> alt
      true -> [child] |> cleanup_html() |> text_content(doc, doc_url, &replaced_img_by_alt_or_src/3) |> String.trim()
    end
  end
end
