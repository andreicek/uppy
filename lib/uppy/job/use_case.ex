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

  def run() do
    with jobs when jobs != [] <- Job.Loader.load_all() do
      run(jobs)
    end
  end

  def run(jobs, count \\ 0)

  def run([job | rest], count) do
    with {:ok, results} <- Checker.UseCase.check_url(job.url),
         {:ok, _ping} <- Ping.UseCase.create(job, results) do
      run(rest, count + 1)
    else
      _ ->
        run(rest, count)
    end
  end

  def run([], count), do: {:ok, count}

  ###

  defp changeset(schema, params) do
    schema
    |> cast(params, @required_fields)
    |> validate_required(@required_fields)
    |> validate_format(:url, @url_format)
  end
end
