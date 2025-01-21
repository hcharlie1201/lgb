defmodule Lgb.Billing do
  @moduledoc """
  The Billing context.
  """

  import Ecto.Query, warn: false
  alias Lgb.Repo

  alias Lgb.Billing.StripeCustomer

  @doc """
  Returns the list of stripe_customers.

  ## Examples

      iex> list_stripe_customers()
      [%StripeCustomer{}, ...]

  """
  def list_stripe_customers do
    Repo.all(StripeCustomer)
  end

  @doc """
  Gets a single stripe_customer.

  Raises `Ecto.NoResultsError` if the Stripe customer does not exist.

  ## Examples

      iex> get_stripe_customer!(123)
      %StripeCustomer{}

      iex> get_stripe_customer!(456)
      ** (Ecto.NoResultsError)

  """
  def get_stripe_customer!(id), do: Repo.get!(StripeCustomer, id)

  @doc """
  Creates a stripe_customer.
  https://docs.stripe.com/api/customers/object?lang=curl
  ## Examples

      iex> create_stripe_customer(%{field: value})
      {:ok, %StripeCustomer{}}

      iex> create_stripe_customer(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_stripe_customer(user, param_body) do
    if Lgb.Accounts.get_stripe_customer(user) do
      {:error, "User already has a Stripe customer"}
    else
      params = %{
        "name" => param_body["name"],
        "email" => user.email,
        "address[line1]" => param_body["address"]["line1"],
        "address[line2]" => param_body["address"]["line2"],
        "address[city]" => param_body["address"]["city"],
        "address[state]" => param_body["address"]["state"],
        "address[postal_code]" => param_body["address"]["postal_code"],
        "address[country]" => param_body["address"]["country"]
      }

      body = URI.encode_query(params)

      case Lgb.ThirdParty.Stripe.Customers.post("", body) do
        {:ok, http_response} ->
          case Poison.decode(http_response.body) do
            {:ok, response} ->
              %StripeCustomer{}
              |> StripeCustomer.changeset(%{"stripe_id" => response["id"], "user_id" => user.id})
              |> Repo.insert()

            {:error, reason} ->
              {:error, reason}
          end

        {:error, reason} ->
          {:error, reason}
      end
    end
  end

  @doc """
  Updates a stripe_customer.

  ## Examples

      iex> update_stripe_customer(stripe_customer, %{field: new_value})
      {:ok, %StripeCustomer{}}

      iex> update_stripe_customer(stripe_customer, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_stripe_customer(%StripeCustomer{} = stripe_customer, attrs) do
    stripe_customer
    |> StripeCustomer.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a stripe_customer.

  ## Examples

      iex> delete_stripe_customer(stripe_customer)
      {:ok, %StripeCustomer{}}

      iex> delete_stripe_customer(stripe_customer)
      {:error, %Ecto.Changeset{}}

  """
  def delete_stripe_customer(%StripeCustomer{} = stripe_customer) do
    Repo.delete(stripe_customer)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking stripe_customer changes.

  ## Examples

      iex> change_stripe_customer(stripe_customer)
      %Ecto.Changeset{data: %StripeCustomer{}}

  """
  def change_stripe_customer(%StripeCustomer{} = stripe_customer, attrs \\ %{}) do
    StripeCustomer.changeset(stripe_customer, attrs)
  end
end
