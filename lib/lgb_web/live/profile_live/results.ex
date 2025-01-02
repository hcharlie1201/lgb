defmodule LgbWeb.ProfileLive.Results do
  alias Lgb.Profiles.Profile
  use LgbWeb, :live_view

  def mount(params, _session, socket) do
    filter = create_filter(params)

    flop_params = %{
      filter: filter
    }

    {profiles, _} = Flop.validate_and_run!(Profile, flop_params, for: Profile)
    IO.inspect(profiles)
    {:ok, assign(socket, profiles: profiles)}
  end

  defp create_filter(params) do
    params
    |> sanitize()
    |> Enum.reduce([], fn {key, value}, acc ->
      case key do
        "min_height_cm" ->
          [%{field: :height_cm, operator: :>=, value: String.to_integer(value)} | acc]

        "max_height_cm" ->
          [%{field: :height_cm, operator: :<=, value: String.to_integer(value)} | acc]
      end
    end)
  end

  defp sanitize(params) do
    params
    |> Enum.reject(fn {_, value} -> value in [nil, ""] end)
  end
end
