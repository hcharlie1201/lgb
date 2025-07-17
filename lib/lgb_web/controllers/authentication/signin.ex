defmodule LgbWeb.Authentication.Signin do
  use LgbWeb, :controller
  alias Lgb.Accounts
  alias Lgb.Authentication.GoogleIdTokenVerifier
  require Logger

  def google_signin(conn, %{"id_token" => id_token} = params) do
    client_id = get_google_client_id()

    # Verify the ID token
    case GoogleIdTokenVerifier.verify_token(id_token, client_id) do
      {:ok, claims} ->
        # Extract verified user information
        user_info = GoogleIdTokenVerifier.extract_user_info(claims)

        # Log the verification for debugging
        Logger.info("Google ID token verified successfully for email: #{user_info.email}")

        # Process the verified user
        process_verified_user(conn, user_info)

      {:error, reason} ->
        Logger.error("Google ID token verification failed: #{inspect(reason)}")

        conn
        |> put_status(:unauthorized)
        |> json(%{error: "Authentication failed", reason: reason})
    end
  end

  def google_signin(conn, _params) do
    conn
    |> put_status(:bad_request)
    |> json(%{error: "Missing id_token parameter"})
  end

  defp process_verified_user(conn, user_info) do
    case Accounts.get_user_by_email(user_info.email) do
      nil ->
        # User does not exist, create a new user with verified information
        user_params = %{
          email: user_info.email
          # You can add more fields from user_info if needed
          # name: user_info.name,
          # google_id: user_info.sub
        }

        case Accounts.register_oauth_user(user_params) do
          {:ok, user} ->
            # Create profile for the new user
            Lgb.Profiles.create_profile(user)

            Logger.info("Created new user from Google OAuth: #{user.email}")

            # Return success response with user info
            conn
            |> put_status(:created)
            |> json(%{
              success: true,
              user: %{
                id: user.id,
                email: user.email,
                message: "User created successfully"
              }
            })

          {:error, changeset} ->
            Logger.error("Failed to create user from Google OAuth: #{inspect(changeset)}")

            conn
            |> put_status(:unprocessable_entity)
            |> json(%{
              error: "Failed to create user account",
              details: format_changeset_errors(changeset)
            })
        end

      user ->
        # User exists, return success response
        Logger.info("Existing user authenticated via Google OAuth: #{user.email}")

        conn
        |> put_status(:ok)
        |> json(%{
          success: true,
          user: %{
            id: user.id,
            email: user.email,
            message: "User authenticated successfully"
          }
        })
    end
  end

  defp get_google_client_id do
    Confex.get_env(:lgb, :google_mobile_client_id) |> dbg()
  end

  defp format_changeset_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Enum.reduce(opts, msg, fn {key, value}, acc ->
        String.replace(acc, "%{#{key}}", to_string(value))
      end)
    end)
  end
end
