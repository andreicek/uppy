defmodule Uppy.Ping.UseCase do
  import Ecto.Changeset

  alias Uppy.{Repo, Job, Ping}

  @required_fields ~w(status_code time job_id)a

  def create(job, params \\ %{})

  def create(%Job{} = job, params) do
    %Ping{}
    |> changeset(job, params)
    |> Repo.insert()
  end

  def create(_job, _params), do: {:error, :job_required}

  ###

  defp changeset(schema, %{id: job_id} = _job, params) do
    schema
    |> cast(params, @required_fields)
    |> change(job_id: job_id)
    |> validate_required(@required_fields)
    |> validate_status_code()
  end

  defp validate_status_code(changeset) do
    validate_change(changeset, :status_code, fn :status_code, status_code ->
      if status_code < 100 or status_code >= 600 do
        [status_code: "invalid status code"]
      else
        []
      end
    end)
  end
end
