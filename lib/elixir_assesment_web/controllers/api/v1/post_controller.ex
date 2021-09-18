defmodule ElixirAssesmentWeb.Api.V1.PostController do
  use ElixirAssesmentWeb, :controller

  alias ElixirAssesment.Datasets.Post
  alias ElixirAssesmentWeb.ErrorHelpers

  def index(conn, params) do
    conn
    |> render(:index, posts: Post.list_posts(params))
  end

  def show(conn, params) do
    post = Post.get_post!(params["id"])

    conn
    |> render(:show, post: post)
  end

  def create(conn, params) do
    case Post.create_post(params) do
      {:ok, post} ->
        conn
        |> put_status(:created)
        |> render(:show, post: post)

      {:error, changeset} ->
        errors = %{
          errors: Ecto.Changeset.traverse_errors(changeset, &ErrorHelpers.translate_error/1)
        }

        conn
        |> put_status(:unprocessable_entity)
        |> json(errors)
    end
  end

  def delete(conn, params) do
    case Post.delete_post(params["id"]) do
      {1, _} -> conn |> send_resp(200, "")
      {0, _} -> conn |> send_resp(400, "")
    end
  end
end
