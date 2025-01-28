defmodule Lgb.Profiles.ProfilePicture do
  use Ecto.Schema
  use Waffle.Ecto.Schema
  import Ecto.Changeset
  @empty_profile "https://lgb-public.s3.us-west-2.amazonaws.com/static/empty-profile.jpg"

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

  def get_picture_url(profile_picture) do
    if profile_picture do
      Lgb.Profiles.ProfilePictureUploader.url(
        {profile_picture.image, profile_picture},
        :original,
        signed: true
      )
    else
      @empty_profile
    end
  end
end
