defmodule Cv.Methods.Method do
  use Ecto.Schema
  import Ecto.Changeset

  schema "methods" do
    field :name, :string
    field :url, :string
    field :version, :integer

    timestamps()
  end

  @doc false
  def changeset(method, attrs) do
    method
    |> cast(attrs, [:name, :url, :version])
    |> validate_required([:name, :url, :version])
  end
end
