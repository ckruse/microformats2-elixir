defmodule Microformats2.Helpers do
  @spec attr_list(String.t() | [any()] | tuple(), String.t()) :: [String.t()]
  def attr_list(node, attr \\ "class") do
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
    node
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

  @spec has_a?(String.t() | [any()] | tuple(), any()) :: boolean()
  def has_a?(node, wanted) do
    node
    |> attr_list()
    |> Enum.filter(&is_a?(&1, wanted))
    |> blank?
  end

  @spec abs_uri(String.t(), String.t(), any()) :: String.t()
  def abs_uri(url, base_url, doc) do
    parsed = URI.parse(url)
    parsed_base = URI.parse(base_url)

    cond do
      # absolute URI
      present?(parsed.scheme) ->
        url

      # protocol relative URI
      blank?(parsed.scheme) and present?(parsed.authority) ->
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

        URI.to_string(%{parsed | scheme: parsed_new_base.scheme, authority: parsed_new_base.authority, path: new_path})
    end
  end

  @spec normalized_key(String.t()) :: String.t() | atom()
  def normalized_key(key) do
    if Application.get_env(:microformats2, :atomize_keys, true),
      do: String.to_atom(key),
      else: key
  end

  @spec valid_mf2_name?(String.t()) :: boolean()
  def valid_mf2_name?(name), do: name =~ ~r/^(?:h|p|e|u|dt)(?:-[a-z0-9]+)?(?:-[a-z]+)+$/

  @spec non_h_type?(String.t()) :: boolean()
  def non_h_type?("p-" <> _ = type), do: valid_mf2_name?(type)
  def non_h_type?("u-" <> _ = type), do: valid_mf2_name?(type)
  def non_h_type?("dt-" <> _ = type), do: valid_mf2_name?(type)
  def non_h_type?("e-" <> _ = type), do: valid_mf2_name?(type)
  def non_h_type?(_), do: false
end
