defmodule Lgb.Meetups.EventLocationPictureUplodaer do
  require Logger
  use Waffle.Definition
  use Waffle.Ecto.Definition

  @versions [:original, :thumb]
  @extension_whitelist ~w(.jpg .jpeg .gif .png .svg)
  @staging_bucket "lgb-user-uploads-staging"
  @production_bucket "lgb-user-uploads"

  def bucket(_) do
    case Application.get_env(:lgb, :environment) do
      :prod -> @production_bucket
      _ -> @staging_bucket
    end
  end

  def validate({file, _}) do
    file_extension = file.file_name |> Path.extname() |> String.downcase()
    Enum.member?(@extension_whitelist, file_extension)
  end

  def storage_dir(_, {_, event_location}) do
    "event_location/main_picture/#{event_location.uuid}"
  end
end
