defmodule ElixirAssesment.Datasets.Post do
  use Ecto.Schema
  import Ecto.Changeset

  alias ElixirAssesment.Datasets.Category

  schema "posts" do
    field :published_at, :utc_datetime, default: nil
    field :status, Ecto.Enum, values: [:draft, :published, :require_moderation], default: :draft
    field :text, :string
    field :title, :string

    many_to_many :categories, Category, join_through: "categories_posts"

    timestamps()
  end

  @doc false
  def changeset(post, attrs) do
    post
    |> cast(attrs, [:title, :text, :status])
    |> validate_required([:title, :text])
  end
end
