defmodule Uppy.Repo.Migrations.AddPings do
  use Ecto.Migration

  def change do
    create table(:pings, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :status_code, :integer
      add :time, :integer

      add(:job_id, references(:jobs, type: :uuid), null: false)

      timestamps(updated_at: false)
    end
  end
end
