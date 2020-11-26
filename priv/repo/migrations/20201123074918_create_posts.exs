defmodule ElixirAssesment.Repo.Migrations.CreatePosts do
  use Ecto.Migration

  def change do
    create table(:posts) do
      add :title, :text, null: false
      add :text, :text, null: false
      add :status, :text, null: false
      add :published_at, :utc_datetime, default: nil

      timestamps()
    end

  end
end
