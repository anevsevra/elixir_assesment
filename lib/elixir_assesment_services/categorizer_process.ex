defmodule ElixirAssesmentServices.CategorizerProcess do
  use GenServer

  alias ElixirAssesment.Datasets
  alias ElixirAssesment.CategorizerTaskSupervisor
  alias ElixirAssesmentServices.Categorizer

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  @impl true
  def init(:ok) do
    {:ok, build_index()}
  end

  @impl true
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

  def run_categorization(post) do
    GenServer.cast(__MODULE__, {:categorize, post})
  end

  def rebuild_index do
    GenServer.cast(__MODULE__, :rebuild_index)
  end

  defp build_index do
    Datasets.list_categories()
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
