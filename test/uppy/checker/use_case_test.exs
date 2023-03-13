defmodule Uppy.Checker.UseCaseTest do
  import Mock
  use ExUnit.Case, async: false

  alias Uppy.{Repo, Checker.UseCase}

  describe "load_all/0" do
    setup do
      :ok = Ecto.Adapters.SQL.Sandbox.checkout(Repo)
    end

    test "makes the request and returns the metadata" do
      url = "https://example.com"
      response = {:ok, %{status: 200}}

      with_mocks([
        {Finch, [], build: fn :get, ^url -> %{} end},
        {Finch, [], request: fn _request, _module -> response end}
      ]) do
        assert {:ok, %{status_code: 200, time: time}} = UseCase.check_url(url)
        assert is_number(time)
      end
    end
  end
end
