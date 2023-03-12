defmodule Uppy.Ping do
  use Ecto.Schema

  alias Uppy.Job

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "pings" do
    field :status_code, :integer
    field :time, :integer

    belongs_to :job, Job

    timestamps(updated_at: false)
  end
end
