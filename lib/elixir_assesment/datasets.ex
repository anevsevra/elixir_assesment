defmodule ElixirAssesment.Datasets do
  @moduledoc """
  The Datasets context.
  """

  import Ecto.Query, warn: false

  alias ElixirAssesment.Repo
  alias ElixirAssesment.Datasets.Category
  alias ElixirAssesment.Datasets.Post
  alias ElixirAssesmentServices.CategorizerProcess

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

  @doc """
  Returns the list of posts.

  ## Examples

      iex> list_posts()
      [%Post{}, ...]

  """
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
           |> Post.changeset(attrs)
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
    |> Post.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a post.

  ## Examples

      iex> delete_category(id)
      {1, nil}

      iex> delete_category(id)
      {0, nil}

  """
  def delete_post(id) do
    from(Post, where: [id: ^id]) |> Repo.delete_all()
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking post changes.

  ## Examples

      iex> change_post(post)
      %Ecto.Changeset{data: %Post{}}

  """
  def change_post(%Post{} = post, attrs \\ %{}) do
    Post.changeset(post, attrs)
  end

  def update_post_and_link_to_categories(post, post_params, category_ids) do
    categories = Repo.all(from c in Category, where: c.id in ^category_ids)

    post
    |> Repo.preload(:categories)
    |> change_post(post_params)
    |> Ecto.Changeset.put_assoc(:categories, categories)
    |> Repo.update()
  end
end
