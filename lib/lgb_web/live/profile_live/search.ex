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
        filters: Profiles.create_filter(params),
        order_by: [:distance]
      }

      profile = Lgb.Accounts.User.current_profile(socket.assigns.current_user)
      query = Profiles.get_other_profiles_distance(profile)

      case Flop.validate_and_run(query, flop_params, for: Profile) do
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

        {"min_weight", weight}, acc ->
          case Integer.parse(weight) do
            {parsed_weight, ""} when parsed_weight <= 0 ->
              [{:min_weight, {"Weight must be between greater than 0", []}} | acc]

            _ ->
              acc
          end

        {"max_weight", weight}, acc ->
          case Integer.parse(weight) do
            {parsed_weight, ""} when parsed_weight > 400 ->
              [{:max_weight, {"Weight must be between less than 400 lbs", []}} | acc]

            _ ->
              acc
          end

        _, acc ->
          acc
      end)
      |> validate_age_order(params)
      |> validate_weight_order(params)

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

  defp validate_weight_order(errors, %{"min_weight" => min_weight, "max_weight" => max_weight})
       when min_weight != "" and max_weight != "" do
    if String.to_integer(max_weight) < String.to_integer(min_weight) do
      [
        {:max_weight, {"Maximum weight must be greater than or equal to minimum weight", []}}
        | errors
      ]
    else
      errors
    end
  end

  defp validate_weight_order(errors, _params), do: errors

  def sanitize(params) do
    params
    |> Enum.reject(fn {_, value} -> value in [nil, ""] end)
  end
end
