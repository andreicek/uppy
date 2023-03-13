defmodule Uppy.Job.UseCaseTest do
  use ExUnit.Case, async: true

  alias Uppy.{Repo, Job.UseCase}

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
end
