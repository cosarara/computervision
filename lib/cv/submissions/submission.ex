defmodule Cv.Submissions.Submission do
  use Ecto.Schema
  import Ecto.Changeset

  schema "submissions" do
    field :image, :binary
    field :mime, :string

    timestamps()
  end

  @doc false
  def changeset(submission, attrs) do
    submission
    |> cast(attrs, [:image, :mime])
    #|> validate_required([:image])
  end
end
