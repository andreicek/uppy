defmodule Uppy.Checker.UseCase do
  def check_url(url) do
    with {time, response} <- :timer.tc(fn -> request(url) end),
         {:ok, %{status: status} = _response} <- response do
      results = %{
        time: time,
        status_code: status
      }

      {:ok, results}
    end
  end

  ###

  defp request(url) do
    :get
    |> Finch.build(url)
    |> Finch.request(Uppy.Finch)
  end
end
