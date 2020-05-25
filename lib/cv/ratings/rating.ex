defmodule Cv.Ratings.Rating do
  use Ecto.Schema
  import Ecto.Changeset

  schema "ratings" do
    field :rating, :integer
    field :method_id, :id, primary_key: true
    field :submission_id, :id, primary_key: true

    timestamps()
  end

  @doc false
  def changeset(rating, attrs) do
    rating
    |> cast(attrs, [:rating])
    |> validate_required([:rating])
    |> unique_constraint(:method_submission, name: :method_submission_i)
  end
end
