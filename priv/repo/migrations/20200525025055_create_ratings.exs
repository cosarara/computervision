defmodule Cv.Repo.Migrations.CreateRatings do
  use Ecto.Migration

  def change do
    create table(:ratings) do
      add :rating, :integer
      add :method_id, references(:methods, on_delete: :delete_all),
        null: false
      add :submission_id, references(:submissions, on_delete: :delete_all),
        null: false

      timestamps()
    end

    create index(:ratings, [:method_id])
    create index(:ratings, [:submission_id])
    create unique_index(:ratings, [:method_id, :submission_id], name: :method_submission_i)
  end
end
