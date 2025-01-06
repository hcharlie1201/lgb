defmodule LgbWeb.ProfileLive.Search do
  use LgbWeb, :live_view
  alias Lgb.Profiles
  alias Lgb.Profiles.Profile

  def mount(_params, _session, socket) do
    {:ok, assign(socket, :form, to_form(%{}))}
  end

  def handle_event("validate", params, socket) do
    form = validate_form(params)

    {:noreply, assign(socket, form: form)}
  end

  def handle_event("search", params, socket) do
    form = validate_form(params)

    if form.errors == [] do
      flop_params = %{
        filters: Profiles.create_filter(params)
      }

      case Flop.validate_and_run(Profile, flop_params, for: Profile) do
        {:ok, {_, metas}} ->
          path = Flop.Phoenix.build_path(~p"/profiles/results", metas)
          {:noreply, push_navigate(socket, to: path)}

        {:error, _} ->
          {:noreply, assign(socket, form: form)}
      end
    else
      {:noreply, assign(socket, form: form)}
    end
  end

  defp validate_form(params) do
    errors =
      params
      |> sanitize()
      |> Enum.reduce([], fn
        {"min_age", age}, acc ->
          case Integer.parse(age) do
            {parsed_age, ""} when parsed_age <= 0 ->
              [{:min_age, {"Age must be between 18 and 100", []}} | acc]

            {parsed_age, ""} when parsed_age < 18 ->
              [{:min_age, {"Age must be between 18 and 100", []}} | acc]

            _ ->
              acc
          end

        {"max_age", age}, acc ->
          case Integer.parse(age) do
            {parsed_age, ""} when parsed_age <= 0 ->
              [{:max_age, {"Age must be between 18 and 100", []}} | acc]

            {parsed_age, ""} when parsed_age > 100 ->
              [{:max_age, {"Age must be between 18 and 100", []}} | acc]

            _ ->
              acc
          end

        _, acc ->
          acc
      end)
      |> validate_age_order(params)

    # Return the form with errors
    to_form(params, errors: errors, action: :validate)
  end

  defp validate_age_order(errors, %{"min_age" => min_age, "max_age" => max_age})
       when min_age != "" and max_age != "" do
    if String.to_integer(max_age) < String.to_integer(min_age) do
      [{:max_age, {"Maximum age must be greater than or equal to minimum age", []}} | errors]
    else
      errors
    end
  end

  defp validate_age_order(errors, _params), do: errors

  def sanitize(params) do
    params
    |> Enum.reject(fn {_, value} -> value in [nil, ""] end)
  end
end
