defmodule Uppy.Ping.UseCaseTest do
  use ExUnit.Case, async: true

  alias Uppy.{Repo, Job, Ping.UseCase}

  describe "create/1" do
    setup do
      :ok = Ecto.Adapters.SQL.Sandbox.checkout(Repo)

      job = %Job{id: Ecto.UUID.generate()} |> Repo.insert!()

      {:ok, job: job}
    end

    test "creates a new ping", %{job: job} do
      params = %{
        "status_code" => 200,
        "time" => 20
      }

      assert {:ok, ping} = UseCase.create(job, params)

      assert ping.time == 20
      assert ping.status_code == 200
      assert ping.job_id == job.id
      assert ping.inserted_at
    end

    test "returns an error with missing fields", %{job: job} do
      params = %{}

      assert {:error, %{errors: errors}} = UseCase.create(job, params)

      assert {:status_code, {"can't be blank", [validation: :required]}} in errors
      assert {:time, {"can't be blank", [validation: :required]}} in errors
    end

    test "returns an error when job is not passed" do
      params = %{}

      assert {:error, :job_required} = UseCase.create(nil, params)
    end

    test "returns an error when saving an incorrect status code", %{job: job} do
      params = %{
        "status_code" => 10,
        "time" => 10
      }

      assert {:error, %{errors: errors}} = UseCase.create(job, params)

      assert {:status_code, {"invalid status code", []}} in errors
    end
  end
end
