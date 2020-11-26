defmodule ElixirAssesment.Repo.Migrations.CreateCategoriesPosts do
  use Ecto.Migration

  def change do
    create table(:categories_posts, primary_key: false) do
      add :category_id, references(:categories, on_delete: :delete_all)
      add :post_id, references(:posts, on_delete: :delete_all)

      timestamps()
    end

    create index(:categories_posts, [:category_id])
    create index(:categories_posts, [:post_id])
    create unique_index(:categories_posts, [:category_id, :post_id])
  end
end
