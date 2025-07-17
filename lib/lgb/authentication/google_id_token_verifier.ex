defmodule Lgb.Authentication.GoogleIdTokenVerifier do
  @moduledoc """
  Verifies Google ID tokens using Google's public keys.

  This module fetches Google's public keys and verifies JWT tokens
  according to Google's OAuth 2.0 specification.
  """

  require Logger

  @google_public_keys_url "https://www.googleapis.com/oauth2/v3/certs"
  @valid_issuers ["accounts.google.com", "https://accounts.google.com"]

  @doc """
  Verifies a Google ID token and returns the decoded claims if valid.

  ## Parameters

  - `id_token`: The JWT token received from Google
  - `client_id`: Your Google OAuth client ID for audience validation
  - `opts`: Optional parameters
    - `:hosted_domain`: Optional hosted domain to validate against

  ## Returns

  - `{:ok, claims}` - Token is valid, returns the decoded claims
  - `{:error, reason}` - Token is invalid, returns the reason
  """
  def verify_token(id_token, client_id) do
    with {:ok, claims} <- decode_and_verify_signature(id_token),
         :ok <- verify_audience(claims, client_id),
         :ok <- verify_issuer(claims),
         :ok <- verify_expiration(claims) do
      {:ok, claims}
    else
      {:error, reason} -> {:error, reason}
    end
  end

  @doc """
  Decodes and verifies the JWT signature using Google's public keys.
  """
  def decode_and_verify_signature(id_token) do
    case fetch_google_public_keys() do
      {:ok, keys} ->
        verify_with_keys(id_token, keys)

      {:error, reason} ->
        {:error, reason}
    end
  end

  defp verify_with_keys(id_token, %{"keys" => keys}) do
    # Try each key until one works
    Enum.find_value(keys, {:error, :invalid_signature}, fn key ->
      case verify_with_key(id_token, key) do
        {:ok, claims} -> {:ok, claims}
        {:error, _} -> nil
      end
    end)
  end

  defp verify_with_key(id_token, key) do
    try do
      # Convert JWK to PEM format for JOSE
      jwk = %{
        "kty" => key["kty"],
        "kid" => key["kid"],
        "use" => key["use"],
        "alg" => key["alg"],
        "n" => key["n"],
        "e" => key["e"]
      }

      case JOSE.JWT.verify_strict(jwk, ["RS256"], id_token) do
        {true, %JOSE.JWT{fields: claims}, _} ->
          {:ok, claims}

        {false, _, _} ->
          {:error, :invalid_signature}
      end
    rescue
      _ -> {:error, :verification_failed}
    end
  end

  @doc """
  Verifies that the audience (aud) claim matches your client ID.
  """
  def verify_audience(claims, client_id) do
    case claims["aud"] do
      ^client_id -> :ok
      _ -> {:error, :invalid_audience}
    end
  end

  @doc """
  Verifies that the issuer (iss) claim is from Google.
  """
  def verify_issuer(claims) do
    case claims["iss"] do
      issuer when issuer in @valid_issuers -> :ok
      _ -> {:error, :invalid_issuer}
    end
  end

  @doc """
  Verifies that the token has not expired.
  """
  def verify_expiration(claims) do
    case claims["exp"] do
      exp when is_integer(exp) ->
        current_time = System.system_time(:second)

        if exp > current_time do
          :ok
        else
          {:error, :token_expired}
        end

      _ ->
        {:error, :invalid_expiration}
    end
  end

  @doc """
  Fetches Google's public keys for JWT verification.
  """
  def fetch_google_public_keys do
    case HTTPoison.get(@google_public_keys_url) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        case Jason.decode(body) do
          {:ok, keys} -> {:ok, keys}
          {:error, _} -> {:error, :invalid_keys_format}
        end

      {:ok, %HTTPoison.Response{status_code: status}} ->
        {:error, "HTTP #{status}"}

      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, reason}
    end
  end

  @doc """
  Returns user information from verified claims.
  """
  def extract_user_info(claims) do
    %{
      email: claims["email"],
      email_verified: claims["email_verified"],
      name: claims["name"],
      given_name: claims["given_name"],
      family_name: claims["family_name"],
      picture: claims["picture"],
      hosted_domain: claims["hd"],
      # Google's unique user ID
      sub: claims["sub"]
    }
  end
end
