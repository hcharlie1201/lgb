defmodule Lgb.Profiles.ProfilePictureUploader do
  require Logger
  use Waffle.Definition
  use Waffle.Ecto.Definition

  @versions [:original, :thumb]
  @extension_whitelist ~w(.jpg .jpeg .gif .png .svg)
  @staging_bucket "lgb-user-uploads-staging"
  @production_bucket "lgb-user-uploads-staging"

  def bucket(_) do
    if Mix.env() == :prod, do: @production_bucket, else: @staging_bucket
  end

  def validate({file, _}) do
    file_extension = file.file_name |> Path.extname() |> String.downcase()
    Enum.member?(@extension_whitelist, file_extension)
  end

  def storage_dir(_, {_, profile_picture}) do
    "profile/pictures/#{profile_picture.uuid}"
  end
end
