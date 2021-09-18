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

  @spec changeset(
          {map, map}
          | %{
              :__struct__ => atom | %{:__changeset__ => map, optional(any) => any},
              optional(atom) => any
            },
          :invalid | %{optional(:__struct__) => none, optional(atom | binary) => any},
          keyword(list(%ElixirAssesment.Datasets.Category{})) | nil
        ) :: Ecto.Changeset.t()
  @doc false
  def changeset(post, attrs, associations \\ nil) do
    post
    |> cast(attrs, [:title, :text, :status, :published_at])
    |> validate_required([:title, :text])
    |> update_associations(associations)
  end

  @spec list_posts(%{optional(String.t()) => any()}) :: [%Post{}]
  def list_posts(query_params \\ %{}) do
    Map.keys(query_params)
    |> Enum.reduce(
      from(p in Post),
      fn key, query ->
        query |> query_posts(Map.take(query_params, [key]))
      end
    )
    |> Repo.all()
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
    |> changeset(post_params, categories: categories)
    |> Repo.update()
  end

  @spec update_associations(
          Ecto.Changeset.t(),
          nil | keyword(list(%ElixirAssesment.Datasets.Category{}))
        ) :: Ecto.Changeset.t()
  defp update_associations(post_changeset, nil), do: post_changeset

  defp update_associations(post_changeset, associations) do
    Enum.reduce(
      associations,
      post_changeset,
      fn assoc, acc ->
        put_assoc(
          acc,
          elem(assoc, 0),
          elem(assoc, 1)
        )
      end
    )
  end

  defp query_posts(query, %{"title" => title}) do
    query |> where([p], p.title == ^title)
  end

  defp query_posts(query, %{"categories" => categories}) do
    prepared_categories_list = Map.values(categories)
    query |> join(:inner, [p], c in assoc(p, :categories)) |> where([_, c], c.tag in ^prepared_categories_list)
  end

  defp query_posts(query, %{"status" => status}) do
    query |> where([p], p.status == ^status)
  end

  defp query_posts(query, %{"created_at_from" => inserted_at_from}) do
    query |> where([p], p.inserted_at >= ^inserted_at_from)
  end

  defp query_posts(query, %{"created_at_to" => inserted_at_to}) do
    query |> where([p], p.inserted_at < ^inserted_at_to)
  end
end
