defmodule ElixirAssesment.Datasets.Post do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query

  alias ElixirAssesment.Datasets.Category
  alias ElixirAssesment.Repo
  alias ElixirAssesmentServices.CategorizerProcess
  alias __MODULE__

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
    |> cast(attrs, [:title, :text, :status, :published_at])
    |> validate_required([:title, :text])
  end


  def list_posts do
    Repo.all(Post)
  end

  @doc """
  Gets a single post.

  Raises `Ecto.NoResultsError` if the Post does not exist.

  ## Examples

      iex> get_post!(123)
      %Post{}

      iex> get_post!(456)
      ** (Ecto.NoResultsError)

  """
  def get_post!(id), do: Repo.get!(Post, id)

  @doc """
  Creates a post.

  ## Examples

      iex> create_post(%{field: value})
      {:ok, %Post{}}

      iex> create_post(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_post(attrs \\ %{}) do
    with {:ok, post} <-
           %Post{}
           |> changeset(attrs)
           |> Repo.insert() do
      CategorizerProcess.run_categorization(post)
      {:ok, post}
    else
      {:error, changeset} -> {:error, changeset}
    end
  end

  @doc """
  Updates a post.

  ## Examples

      iex> update_post(post, %{field: new_value})
      {:ok, %Post{}}

      iex> update_post(post, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_post(%Post{} = post, attrs) do
    post
    |> changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a post.

  ## Examples

      iex> delete_post(id)
      {1, nil}

      iex> delete_post(id)
      {0, nil}

  """
  def delete_post(id) do
    from(Post, where: [id: ^id]) |> Repo.delete_all()
  end


  def update_post_and_link_to_categories(post, post_params, category_ids) do
    categories = Repo.all(from c in Category, where: c.id in ^category_ids)

    post
    |> Repo.preload(:categories)
    |> changeset(post_params)
    |> Ecto.Changeset.put_assoc(:categories, categories)
    |> Repo.update()
  end
end
