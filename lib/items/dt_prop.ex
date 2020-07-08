defmodule Microformats2.Items.DtProp do
  import Microformats2.Helpers

  alias Microformats2.Helpers.DateTimeNormalizer
  alias Microformats2.ParserState

  defp parse_infos_from_state(state) do
    %{
      date_parts: state.dates,
      implied_timezone: state.implied_timezone,
      value: nil,
      date: nil,
      time: nil,
      zone: nil,
      timezone_offset: nil
    }
  end

  def parsed_prop(child = {elem, _, _}, state) do
    dt = Floki.attribute([child], "datetime") |> List.first()
    title = Floki.attribute([child], "title") |> List.first()
    value = Floki.attribute([child], "value") |> List.first()

    parse_state = parse_value_class([child], parse_infos_from_state(state))

    {value, timezone_offset, dates} =
      if present?(parse_state) do
        {parse_state[:value], parse_state[:implied_timezone], parse_state[:date_parts]}
      else
        value =
          cond do
            elem in ["time", "ins", "del"] && present?(dt) -> dt
            elem == "abbr" && !is_nil(title) -> title
            elem in ["data", "input"] && !is_nil(value) -> value
            true -> [child] |> cleanup_html() |> text_content()
          end
          |> stripped_or_nil()

        timezone =
          if !Regex.match?(~r/^(\d{4}-\d{2}-\d{2})$/, value) do
            data = (Regex.run(~r/Z|[+-]\d{1,2}:?(\d{2})?$/i, value) || []) |> List.first()

            if blank?(state.implied_timezone) && present?(data),
              do: data,
              else: state.implied_timezone
          end

        data = (Regex.run(~r/(\d{4}-\d{2}-\d{2})/, value) || []) |> List.first()

        if data,
          do: {value, timezone, [data | state.dates]},
          else: {value, timezone, state.dates}
      end

    fixed_value =
      if (value =~ ~r/^\d{1,2}:\d{2}(:\d{2})?(Z|[+-]\d{2}:?\d{2}?)?$/ ||
            value =~ ~r/^\d{1,2}(:\d{2})?(:\d{2})?[ap]\.?m\.?$/i) && present?(dates) do
        {time, _offset} = DateTimeNormalizer.normalized_time_zone_offset(value)
        time = DateTimeNormalizer.normalized_time_format(time)
        [date | _] = dates

        "#{date} #{stripped_or_nil(time)}"
      else
        value
      end

    {fixed_value, %ParserState{state | implied_timezone: timezone_offset, dates: dates}}
  end

  defp parse_value_class(node, parse_infos) do
    nodes = Floki.find(node, ">[class~=value], >[class~=value-title]")

    if present?(nodes) do
      nodes
      |> Enum.map(&value_for_node/1)
      |> parse_date_values(parse_infos)
    end
  end

  defp value_for_node({elem, _, _} = node) do
    alt = Floki.attribute([node], "alt") |> List.first()

    cond do
      Enum.member?(attr_list([node], "class"), "value-title") ->
        Floki.attribute([node], "title") |> List.first()

      elem in ~w[img area] && !is_nil(alt) ->
        alt

      elem == "data" ->
        value = Floki.attribute([node], "value") |> List.first()

        if is_nil(value),
          do: [node] |> Floki.text() |> stripped_or_nil(),
          else: value

      elem == "abbr" ->
        title = Floki.attribute([node], "title") |> List.first()

        if is_nil(title),
          do: [node] |> Floki.text() |> stripped_or_nil(),
          else: title

      elem in ~w[del ins time] ->
        datetime = Floki.attribute([node], "datetime") |> List.first()

        if is_nil(datetime),
          do: [node] |> Floki.text() |> stripped_or_nil(),
          else: datetime

      true ->
        [node] |> Floki.text() |> stripped_or_nil()
    end
  end

  defp parse_date_values(parts, parse_infos)
  defp parse_date_values([], parse_info), do: parse_info

  defp parse_date_values([nil | rest], parse_infos),
    do: parse_date_values(rest, parse_infos)

  defp parse_date_values([part | rest], parse_infos) do
    updated_parse_infos =
      cond do
        # we found the date/time value, return it and be done with this
        part =~ ~r/^\d{4}-\d{2}-\d{2}[ T]\d{2}:\d{2}(:\d{2})?(Z|[+-]\d{2}:?\d{2})?$/ ->
          part

        # we found a time value, possibly with time zone information
        part =~ ~r/^\d{1,2}:\d{2}(:\d{2})?(Z|[+-]\d{1,2}:?\d{2})?$/ ||
            (part =~ ~r/^\d{1,2}(:\d{2})?(:\d{2})?[ap]\.?m\.?$/i && blank?(parse_infos[:time])) ->
          {time, offset} = DateTimeNormalizer.normalized_time_zone_offset(part)

          parse_infos
          |> Map.merge(%{time: time, timezone_offset: offset})
          |> maybe_put_implied_timezone(offset)

        # we found a valid date and no other date has been found
        part =~ ~r/^\d{4}-\d{2}-\d{2}$/ && blank?(parse_infos[:date]) ->
          Map.put(parse_infos, :date, part)

        # we found a ordinal date and no other date has been found
        part =~ ~r/^\d{4}-\d{3}$/ && blank?(parse_infos[:date]) ->
          Map.put(parse_infos, :date, DateTimeNormalizer.normalized_ordinal_date(part))

        # we found a valid time zone and no other zone has been found
        part =~ ~r/^(Z|[+-]\d{1,2}:?(\d{2})?)$/ && blank?(parse_infos[:zone]) ->
          {_, offset} = DateTimeNormalizer.normalized_time_zone_offset(part)

          parse_infos
          |> Map.merge(%{zone: part, timezone_offset: offset})
          |> maybe_put_implied_timezone(offset)

        # nothing valid found, no state change
        true ->
          {:next, parse_infos}
      end
      |> maybe_save_date_part()
      |> maybe_fix_time_part()
      |> maybe_save_date_or_time()

    if is_binary(updated_parse_infos) do
      date = String.replace(updated_parse_infos, ~r/[T ].*$/, "")

      parse_infos
      |> Map.put(:date, updated_parse_infos)
      |> Map.update!(:date_parts, &[date | &1])
    else
      parse_date_values(rest, updated_parse_infos)
    end
  end

  defp maybe_save_date_or_time(str) when is_binary(str), do: str
  defp maybe_save_date_or_time({:next, parse_infos}), do: {:next, parse_infos}

  defp maybe_save_date_or_time(parse_infos) do
    cond do
      blank?(parse_infos[:date]) && present?(parse_infos[:time]) ->
        time = DateTimeNormalizer.normalized_time_format(parse_infos[:time])
        Map.merge(parse_infos, %{value: stripped_or_nil(time), time: time})

      present?(parse_infos[:date]) && blank?(parse_infos[:time]) ->
        Map.put(parse_infos, :value, String.trim_trailing(parse_infos[:date], "T"))

      true ->
        time = DateTimeNormalizer.normalized_time_format(parse_infos[:time])
        date = String.trim_trailing(parse_infos[:date], "T")
        value = "#{date} #{stripped_or_nil(time)}"
        Map.merge(parse_infos, %{value: value, time: time})
    end
  end

  defp maybe_save_date_part(str) when is_binary(str), do: str
  defp maybe_save_date_part({:next, parse_infos}), do: {:next, parse_infos}

  defp maybe_save_date_part(parse_infos) do
    if present?(parse_infos[:date]) && !Enum.member?(parse_infos[:date_parts], parse_infos[:date]),
      do: Map.update!(parse_infos, :date_parts, &[parse_infos[:date] | &1]),
      else: parse_infos
  end

  defp maybe_fix_time_part(str) when is_binary(str), do: str
  defp maybe_fix_time_part({:next, parse_infos}), do: {:next, parse_infos}

  defp maybe_fix_time_part(parse_infos) do
    if present?(parse_infos[:zone]) && present?(parse_infos[:time]),
      do: Map.put(parse_infos, :time, "#{parse_infos[:time]}#{parse_infos[:zone]}"),
      else: parse_infos
  end

  defp maybe_put_implied_timezone(map, value) do
    if blank?(map[:implied_timezone]) && present?(value),
      do: Map.put(map, :implied_timezone, value),
      else: map
  end
end
