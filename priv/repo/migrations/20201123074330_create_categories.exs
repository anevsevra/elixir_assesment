defmodule ElixirAssesment.Repo.Migrations.CreateCategories do
  use Ecto.Migration

  def change do
    create table(:categories) do
      add :name, :text, null: false
      add :tag, :text, null: false
      add :description, :text
      add :need_moderation, :boolean, default: false, null: false
      add :keywords, {:array, :string}, null: false

      timestamps()
    end

    create unique_index(:categories, [:tag])
  end
end
