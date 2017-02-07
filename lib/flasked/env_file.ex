defmodule Flasked.EnvFile do
  @moduledoc false

  @key_value_delimiter "="

  def load do
    current_env = Mix.env
    |> to_string
    |> String.downcase

    [".env", ".env.#{current_env}"]
    |> load
  end

  def load(env_files) do
    for path <- env_files do
      if File.exists?(path) do
        content = File.read!(path)
        content |> parse
      end
    end
  end

  defp parse(content), do: content |> get_pairs |> load_env

  defp parse_line(line) do
    [key, value] = line
    |> String.strip
    |> String.split(@key_value_delimiter, parts: 2)

    [key, parse_value(value)]
  end

  defp parse_value(value) do
    case String.starts_with?(value, "\"") do
      true -> unquote_string(value)
      _ -> value |> String.split("#") |> List.first
    end
  end

  defp get_pairs(content) do
    content
    |> String.split("\n")
    |> Enum.reject(&blank_entry?/1)
    |> Enum.reject(&comment_entry?/1)
    |> Enum.map(&parse_line/1)
  end

  defp blank_entry?(string), do: string == ""
  defp comment_entry?(string), do: String.match?(string, ~r(^\s*#))

  defp unquote_string(string) do
    string
    |> String.split(~r{(?<!\\)"}, parts: 3)
    |> Enum.drop(1)
    |> List.first
    |> String.replace(~r{\\"}, ~S("))
  end

  defp load_env(pairs) when is_list(pairs) do
    Enum.each(pairs, fn([key, value]) ->
      System.put_env(String.upcase(key), value)
    end)
  end

end
