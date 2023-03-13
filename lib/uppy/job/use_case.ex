defmodule Uppy.Job.UseCase do
  import Ecto.Changeset

  alias Uppy.{Repo, Job, Checker, Ping}

  @required_fields ~w(url)a
  @url_format ~r'^http(?:s)?://\S+\.\S+$'i

  def create(params \\ %{}) do
    %Job{}
    |> changeset(params)
    |> Repo.insert()
  end

  def run_all do
    Job.Loader.load_all()
    |> run_all()
  end

  def run_all(jobs, count \\ 0)

  def run_all([job | rest], count) do
    case run(job) do
      {:ok, _ping} ->
        run_all(rest, count + 1)

      _ ->
        run_all(rest, count)
    end
  end

  def run_all([], count), do: {:ok, count}

  def run(job) do
    with {:ok, results} <- Checker.UseCase.check_url(job.url) do
      Ping.UseCase.create(job, results)
    end
  end

  ###

  defp changeset(schema, params) do
    schema
    |> cast(params, @required_fields)
    |> validate_required(@required_fields)
    |> validate_format(:url, @url_format)
  end
end
