defmodule ElixirAssesmentWeb.Api.V1.CategoryView do
  use ElixirAssesmentWeb, :view

  def render("index.json", %{categories: categories}) do
    %{
      data: %{
        categories:
          render_many(categories, __MODULE__, "category.json")
      }
    }
  end

  def render("show.json", %{category: category}) do
    %{
      data: render_one(category, __MODULE__, "category.json")
    }
  end

  def render("category.json", %{category: category}) do
    %{
      category: %{
        id: category.id,
        name: category.name,
        keywords: category.keywords,
        description: category.description,
        need_moderation: category.need_moderation,
        tag: category.tag,
        inserted_at: category.inserted_at,
        updated_at: category.updated_at
      }
    }
  end
end
