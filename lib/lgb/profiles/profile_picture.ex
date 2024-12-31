defmodule Lgb.Profiles.ProfilePicture do
  use Ecto.Schema
  use Waffle.Ecto.Schema
  import Ecto.Changeset

  schema "profile_pictures" do
    belongs_to :profile, Lgb.Profiles.Profile
    field :image, Lgb.Profiles.ProfilePictureUploader.Type
    field :uuid, Ecto.UUID, default: Ecto.UUID.generate()

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(profile_picture, attrs) do
    profile_picture
    |> cast(attrs, [:profile_id])
    |> cast_attachments(attrs, [:image])
  end
end
