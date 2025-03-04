defmodule Lgb.Uploader do
  def cleanup_temp_file(entry) do
    path = generate_temp_path(entry.client_name)

    File.rm!(path)
  end

  @doc """
  Add one image
  """
  def maybe_add_image(attrs, nil), do: attrs

  def maybe_add_image(attrs, %{entry: entry, path: path}) do
    dest = generate_temp_path(entry.client_name)

    File.cp!(path, dest)

    image_upload = %Plug.Upload{
      path: dest,
      filename: entry.client_name,
      content_type: entry.client_type
    }

    Map.put(attrs, "image", image_upload)
  end

  def error_to_string(:too_large), do: "Too large"
  def error_to_string(:not_accepted), do: "You have selected an unacceptable file type"
  def error_to_string(:too_many_files), do: "You have selected too many files"

  defp generate_temp_path(filename) do
    Path.join(
      Application.app_dir(:lgb, "priv/static/uploads"),
      filename
    )
  end
end
