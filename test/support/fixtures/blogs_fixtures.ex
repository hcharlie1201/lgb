defmodule Lgb.BlogsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Lgb.Blogs` context.
  """

  @doc """
  Generate a post.
  """
  def post_fixture(attrs \\ %{}) do
    {:ok, post} =
      attrs
      |> Enum.into(%{
        content: "some content",
        title: "some title"
      })
      |> Lgb.Blogs.create_post()

    post
  end
end
