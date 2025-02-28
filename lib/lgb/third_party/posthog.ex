defmodule Lgb.ThirdParty.Posthog do
  require Logger
  alias ElixirSense.Log

  @key_mapping %{
    # Map internal keys to PostHog feature flag keys
    meetup: "meetup"
  }

  def enabled?(key, user_uuid) when is_atom(key) do
    posthog_key = Map.get(@key_mapping, key, to_string(key))

    # Use a direct approach to safely check feature flags
    try do
      case Posthog.feature_flags(user_uuid) do
        {:ok, %{feature_flags: flags}} ->
          # Access the flag using the mapped key
          Map.get(flags, posthog_key, false)

        # Fallback for any other response format
        _ ->
          false
      end
    rescue
      # Catch any exceptions and default to false
      _ ->
        Logger.error("feature flag error")
        false
    end
  end
end
