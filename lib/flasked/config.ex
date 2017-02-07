defmodule Flasked.Config do
  @moduledoc false

  def check do
    unless otp_app_key_present?, do: raise(ArgumentError, message: ":otp_app is missing in :flasked configuration")
    unless map_key_present? do
      raise(ArgumentError, message: "Either :map_file or :map_data is missing in :flasked configuration")
    end
  end

  defp otp_app_key_present? do
    Dict.has_key?(get_env, :otp_app)
  end

  defp map_key_present? do
    env = get_env
    Dict.has_key?(env, :map_file) || Dict.has_key?(env, :map_data)
  end

  defp get_env, do: Application.get_all_env(:flasked)

  def otp_app, do: Application.get_env(:flasked, :otp_app)
  def map_file, do: Application.get_env(:flasked, :map_file)
  def map_data, do: Application.get_env(:flasked, :map_data)
end
