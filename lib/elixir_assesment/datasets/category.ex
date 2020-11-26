defmodule ElixirAssesment.Datasets.Category do
  use Ecto.Schema
  import Ecto.Changeset

  alias ElixirAssesment.Datasets.Post

  schema "categories" do
    field :description, :string
    field :keywords, {:array, :string}
    field :name, :string
    field :need_moderation, :boolean, default: false
    field :tag, :string

    many_to_many :posts, Post, join_through: "categories_posts"

    timestamps()
  end

  @doc false
  def changeset(category, attrs) do
    category
    |> cast(attrs, [:name, :tag, :description, :need_moderation, :keywords])
    |> validate_required([:name, :tag, :keywords])
    |> unique_constraint(:tag)
    |> validate_length(:keywords, min: 1)
  end
end
