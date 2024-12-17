defmodule Lgb.Profiles.ProfilePictureUploader do
  require Logger
  use Waffle.Definition
  use Waffle.Ecto.Definition

  @versions [:original, :thumb]
  @extension_whitelist ~w(.jpg .jpeg .gif .png)

  def acl(:thumb, _), do: :public_read

  def bucket(_) do
    if Mix.env() == :prod do
      "lgb-user-uploads"
    else
      "lg-user-uploads-staging"
    end
  end

  def validate({file, _}) do
    file_extension = file.file_name |> Path.extname() |> String.downcase()
    Enum.member?(@extension_whitelist, file_extension)
  end

  def filename(_version, {file, profile_picture}) do
    file.file_name
  end

  def storage_dir(_, {file, user}) do
    "avatars/#{user.id}/#{file.file_name}"
  end

  def default_url(:thumb) do
    "https://placehold.it/100x100"
  end
end
