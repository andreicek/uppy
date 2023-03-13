defmodule Uppy.Job.UseCaseTest do
  import Mock

  use ExUnit.Case, async: true

  alias Uppy.{Repo, Checker, Ping, Job, Job.UseCase}

  describe "create/1" do
    setup do
      :ok = Ecto.Adapters.SQL.Sandbox.checkout(Repo)
    end

    test "creates a new job" do
      params = %{
        "url" => "https://example.org"
      }

      assert {:ok, job} = UseCase.create(params)

      assert job.url == "https://example.org"
    end

    test "returns an error with missing fields" do
      params = %{}

      assert {:error, %{errors: errors}} = UseCase.create(params)

      assert {:url, {"can't be blank", [validation: :required]}} in errors
    end

    test "returns an error when an invalid URL is provided" do
      params = %{
        "url" => "not-a-url"
      }

      assert {:error, %{errors: errors}} = UseCase.create(params)

      assert {:url, {"has invalid format", [validation: :format]}} in errors
    end
  end

  describe "run_all/0" do
    setup do
      :ok = Ecto.Adapters.SQL.Sandbox.checkout(Repo)

      jobs =
        for index <- 1..4 do
          %Job{url: "https://#{index}.example.com"}
          |> Repo.insert!()
        end

      {:ok, jobs: jobs}
    end

    test "checks status of all configured jobs", %{jobs: jobs} do
      jobs_count = length(jobs)
      response = {:ok, %{time: 100, status_code: 200}}

      with_mock(Checker.UseCase, check_url: fn _url -> response end) do
        assert {:ok, ^jobs_count} = UseCase.run_all()

        pings = Repo.all(Ping)

        assert length(pings) == 4
      end
    end

    test "returns the correct count if a ping failed" do
      success = {:ok, %{time: 100, status_code: 200}}
      fail = {:error, :some_error}

      with_mock(
        Checker.UseCase,
        check_url: fn
          "https://1.example.com" -> fail
          _url -> success
        end
      ) do
        assert {:ok, 3} = UseCase.run_all()
      end
    end
  end

  describe "run/1" do
    setup do
      :ok = Ecto.Adapters.SQL.Sandbox.checkout(Repo)

      job =
        %Job{url: "https://example.com"}
        |> Repo.insert!()

      {:ok, job: job}
    end

    test "checks status of a job", %{job: job} do
      response = {:ok, %{time: 100, status_code: 200}}

      with_mock(Checker.UseCase, check_url: fn _url -> response end) do
        assert {:ok, %{id: ping_id} = _ping} = UseCase.run(job)

        assert %{id: ^ping_id, time: 100, status_code: 200} = Repo.one(Ping)
      end
    end

    test "it does not store a ping if a job failed", %{job: job} do
      fail = {:error, :some_error}

      with_mock(Checker.UseCase, check_url: fn _url -> fail end) do
        assert fail == UseCase.run(job)

        refute Repo.one(Ping)
      end
    end
  end
end
