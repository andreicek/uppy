defmodule Uppy.Job.LoaderTest do
  use ExUnit.Case, async: true

  alias Uppy.{Repo, Job, Job.Loader}

  describe "load_all/0" do
    setup do
      :ok = Ecto.Adapters.SQL.Sandbox.checkout(Repo)

      jobs =
        for _ <- 1..4 do
          %Job{url: "https://example.com"}
          |> Repo.insert!()
        end

      {:ok, jobs: jobs}
    end

    test "returns all jobs", %{jobs: jobs} do
      assert jobs == Loader.load_all()
    end
  end
end
