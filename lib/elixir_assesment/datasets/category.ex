defmodule ElixirAssesment.Datasets.Category do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query, warn: false

  alias ElixirAssesment.Datasets.Post
  alias ElixirAssesment.Repo
  alias ElixirAssesmentServices.CategorizerProcess
  alias __MODULE__

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

  @doc """
  Returns the list of categories.

  ## Examples

      iex> list_categories()
      [%Category{}, ...]

  """
  def list_categories do
    Repo.all(Category)
  end

  @doc """
  Gets a single category.

  Raises `Ecto.NoResultsError` if the Category does not exist.

  ## Examples

      iex> get_category!(123)
      %Category{}

      iex> get_category!(456)
      **(Ecto.NoResultsError)

  """
  def get_category!(id), do: Repo.get!(Category, id)

  @doc """
  Creates a category.

  ## Examples

      iex> create_category(%{field: value})
      {:ok, %Category{}}

      iex> create_category(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_category(attrs \\ %{}) do
    %Category{}
    |> Category.changeset(attrs)
    |> Repo.insert()
    |> case do
      {:ok, category} ->
        CategorizerProcess.rebuild_index()
        {:ok, category}

      {:error, changeset} ->
        {:error, changeset}
    end
  end

  @doc """
  Deletes a category.

  ## Examples

      iex> delete_category(id)
      {1, nil}

      iex> delete_category(id)
      {0, nil}

  """
  def delete_category(id) do
    from(Category, where: [id: ^id])
    |> Repo.delete_all()
    |> case do
      {count, nil} ->
        CategorizerProcess.rebuild_index()
        {count, nil}

      {0, nil} ->
        {0, nil}
    end
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking category changes.

  ## Examples

      iex> change_category(category)
      %Ecto.Changeset{data: %Category{}}

  """
  def change_category(%Category{} = category, attrs \\ %{}) do
    Category.changeset(category, attrs)
  end
end
