defmodule Cv.Repo.Migrations.CreateMethods do
  use Ecto.Migration

  def change do
    create table(:methods) do
      add :name, :string
      add :url, :string
      add :version, :integer

      timestamps()
    end

  end
end
