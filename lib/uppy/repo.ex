defmodule Uppy.Repo do
  use Ecto.Repo,
    otp_app: :uppy,
    adapter: Ecto.Adapters.SQLite3
end
