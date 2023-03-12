defmodule Uppy.Job.Loader do
  alias Uppy.{Repo, Job}

  def load_all do
    Repo.all(Job)
  end
end
