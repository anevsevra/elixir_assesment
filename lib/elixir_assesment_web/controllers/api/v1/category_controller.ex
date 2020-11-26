defmodule ElixirAssesmentWeb.Api.V1.CategoryController do
  use ElixirAssesmentWeb, :controller

  alias ElixirAssesment.Datasets
  alias ElixirAssesmentWeb.ErrorHelpers

  def index(conn, _) do
    conn
    |> render(:index, categories: Datasets.list_categories())
  end

  def show(conn, params) do
    category = Datasets.get_category!(params["id"])

    conn
    |> render(:show, category: category)
  end

  def create(conn, params) do
    case Datasets.create_category(params) do
      {:ok, category} ->
        conn
        |> put_status(:created)
        |> render(:show, category: category)

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
    case Datasets.delete_category(params["id"]) do
      {1, _} -> conn |> send_resp(200, "")
      {0, _} -> conn |> send_resp(400, "")
    end
  end
end
