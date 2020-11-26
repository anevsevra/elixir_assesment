defmodule ElixirAssesmentWeb.Api.V1.PostController do
  use ElixirAssesmentWeb, :controller

  alias ElixirAssesment.Datasets
  alias ElixirAssesmentWeb.ErrorHelpers

  def index(conn, _) do
    conn
    |> render(:index, posts: Datasets.list_posts())
  end

  def show(conn, params) do
    post = Datasets.get_post!(params["id"])

    conn
    |> render(:show, post: post)
  end

  def create(conn, params) do
    case Datasets.create_post(params) do
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
    case Datasets.delete_post(params["id"]) do
      {1, _} -> conn |> send_resp(200, "")
      {0, _} -> conn |> send_resp(400, "")
    end
  end
end
