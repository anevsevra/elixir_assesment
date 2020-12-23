alias ElixirAssesment.Repo
alias ElixirAssesment.Datasets.Category
alias ElixirAssesment.Datasets.Post

categories = [
  %{
    description: "Category that does not require moderation",
    keywords: ~w[apple tree fruit],
    name: "gardening",
    need_moderation: false,
    tag: "gardening"
  },
  %{
    description: "Another category that does not require moderation",
    keywords: ~w[plane helicopter superman],
    name: "aviation",
    need_moderation: false,
    tag: "aviation"
  },
  %{
    description: "Category that requires moderation",
    keywords: ~w[nasty evil],
    name: "nasty_category",
    need_moderation: true,
    tag: "nasty"
  }
]

posts = [
  %{
    title: "About Elixir",
    text: "Nice PL!"
  }
]

Enum.each(categories, fn attrs -> Category.changeset(%Category{}, attrs) |> Repo.insert! end)
Enum.each(posts, fn attrs -> Post.changeset(%Post{}, attrs) |> Repo.insert! end)
