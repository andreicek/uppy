defmodule Uppy.Job do
  use Ecto.Schema

  alias Uppy.Ping

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "jobs" do
    field :url, :string

    has_many :pings, Ping

    timestamps()
  end
end
