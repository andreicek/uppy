defmodule Uppy.Job.UseCase do
  import Ecto.Changeset

  alias Uppy.{Repo, Job}

  @required_fields ~w(url)a
  @url_format ~r'^http(?:s)?://\S+\.\S+$'i

  def create(params \\ %{}) do
    %Job{}
    |> changeset(params)
    |> Repo.insert()
  end

  ###

  defp changeset(schema, params) do
    schema
    |> cast(params, @required_fields)
    |> validate_required(@required_fields)
    |> validate_format(:url, @url_format)
  end
end
