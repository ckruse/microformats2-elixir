defmodule Microformats2.Helpers.DateTimeNormalizer do
  @moduledoc false
  import Microformats2.Helpers

  def normalized_time_format(time) do
    match = Regex.run(~r/(\d{1,2}):?(\d{2})?:?(\d{2})?(a\.?m\.?|p\.?m\.?)?/i, time)

    if blank?(Enum.at(match, 4)),
      # we found no am/pm, return the time
      do: time,
      else: adjust_for_am_pm(match)
  end

  defp adjust_for_am_pm([_, hour_str, minute_str, second_str, merid_str]) do
    merid =
      merid_str
      |> String.replace(".", "")
      |> String.downcase()

    hours =
      hour_str
      |> String.to_integer(10)
      |> normalize_hour(merid)

    minutes =
      if present?(minute_str),
        do: minute_str,
        else: "00"

    seconds =
      if present?(second_str),
        do: second_str,
        else: nil

    if present?(seconds),
      do: "#{hours}:#{minutes}:#{seconds}",
      else: "#{hours}:#{minutes}"
  end

  defp normalize_hour(hour, "pm") when hour < 12,
    do: normalize_hour(hour + 12, "am")

  defp normalize_hour(hour, _merid),
    do: String.pad_leading(Integer.to_string(hour), 2, "0")

  def normalized_ordinal_date(date) do
    [str_year, str_day] = String.split(date, "-", parts: 2)
    year = String.to_integer(str_year)
    day = String.to_integer(str_day)

    cond do
      day < 367 && day > 0 ->
        {:ok, date} = Date.new(year, 1, 1)
        date = Date.add(date, day)

        if date.year == year do
          mon = if date.month < 10, do: "0#{date.month}", else: date.month
          day = if date.day < 10, do: "0#{date.day}", else: date.day

          "#{date.year}-#{mon}-#{day}"
        else
          ""
        end

      true ->
        ""
    end
  end

  def normalized_time_zone_offset(time) do
    matchdata = Regex.run(~r/Z|[+-]\d{1,2}:?(\d{2})?$/i, time)

    cond do
      is_nil(matchdata) ->
        {time, nil}

      List.first(matchdata) != "Z" ->
        zone_str = String.replace(List.first(matchdata), ":", "")
        plus_minus = String.slice(zone_str, 0, 1)
        offset = String.slice(zone_str, 1..-1)

        correctedOffset =
          plus_minus <>
            (if(String.length(offset) <= 2,
               do: offset <> "00",
               else: offset
             )
             |> String.pad_leading(4, "0"))

        {String.replace(time, ~r/Z?[+-]\d{1,2}:?(\d{2})?$/i, correctedOffset), correctedOffset}

      true ->
        {time, nil}
    end
  end
end
