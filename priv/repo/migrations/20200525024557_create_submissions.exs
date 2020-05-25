defmodule Cv.Repo.Migrations.CreateSubmissions do
  use Ecto.Migration

  def change do
    create table(:submissions) do
      add :image, :binary
      add :mime, :text

      timestamps()
    end

  end
end
