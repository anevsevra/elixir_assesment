defmodule ElixirAssesmentServices.CategorizerProcess do
  use GenServer

  alias ElixirAssesment.Datasets.Category
  alias ElixirAssesment.CategorizerTaskSupervisor
  alias ElixirAssesmentServices.Categorizer

  @type index() :: %{optional(String.t()) => %{id: integer(), moderation: boolean()}}

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  @impl true
  @spec init(:ok) :: {:ok, %{optional(String.t()) => integer()}}
  def init(:ok) do
    {:ok, build_index()}
  end

  @impl true
  @spec handle_cast(
          atom()
          | {atom(), %ElixirAssesment.Datasets.Post{}},
          %{optional(String.t()) => integer()}
        ) ::
          {:noreply, index()}
  def handle_cast({:categorize, post}, index) do
    Task.Supervisor.start_child(
      CategorizerTaskSupervisor,
      Categorizer,
      :call,
      [post, index],
      restart: :transient
    )

    {:noreply, index}
  end

  @impl true
  def handle_cast(:rebuild_index, _) do
    {:noreply, build_index()}
  end

  @spec run_categorization(%ElixirAssesment.Datasets.Post{}) :: :ok
  def run_categorization(post) do
    GenServer.cast(__MODULE__, {:categorize, post})
  end

  @spec rebuild_index :: :ok
  def rebuild_index do
    GenServer.cast(__MODULE__, :rebuild_index)
  end

  # same keyword may be present in different categories
  @spec build_index() :: index()
  defp build_index do
    Category.list_categories()
    |> Enum.reduce(
      %{},
      fn category, acc ->
        Enum.reduce(
          category.keywords,
          %{},
          fn keyword, inner_acc ->
            Map.put(inner_acc, keyword, %{
              id: category.id,
              moderation: category.need_moderation
            })
          end
        )
        |> Map.merge(
          acc,
          fn _k, v1, v2 ->
            cond do
              v1.moderation -> v1
              v2.moderation -> v2
              true -> v1
            end
          end
        )
      end
    )
  end
end
