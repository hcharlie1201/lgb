defmodule LgbWeb.BlogLive do
  use LgbWeb, :live_view

  def render(assigns) do
    ~H"""
    <div class="container mx-auto px-4 py-8">
      <div class="mx-auto max-w-xl">
        <h1 class="premium-title mb-4 text-center">Stories</h1>

        <form class="mb-6" phx-change="search" phx-submit="search">
          <input
            class="w-full rounded-md border px-4 py-2 focus:outline-none focus:ring-2 focus:ring-blue-500"
            type="text"
            name="query"
            value={@search_query}
            placeholder="Search blogs..."
          />
        </form>

        <div class="space-y-4">
          <%= if length(@filtered_blogs) > 0 do %>
            <%= for blog <- @filtered_blogs do %>
              <div class="rounded-lg bg-white p-4 shadow">
                <h2 class="mb-2 text-xl">{blog.title}</h2>
                <p>{blog.excerpt}</p>
                <.link navigate={~p"/blogs/#{blog.slug}"} class="text-blue-500 hover:underline">
                  Read more
                </.link>
              </div>
            <% end %>
          <% else %>
            <p class="text-center text-gray-500">No results found.</p>
          <% end %>
        </div>
      </div>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    blogs = load_blogs()

    socket =
      socket
      |> assign(
        blogs: blogs,
        search_query: "",
        filtered_blogs: blogs
      )

    {:ok, socket}
  end

  defp load_blogs do
    [
      %{
        id: 1,
        title: "The Idea",
        slug: "strategy",
        excerpt: "This post is dedicated about explaing the mission and our journey...",
        content: "Full content of the first blog post..."
      },
      %{
        id: 2,
        title: "Ways of Thinking",
        slug: "marketing",
        excerpt: "This is a short excerpt of the ways of thinking...",
        content: "Full content of the second blog post..."
      }
      # Add more blog entries
    ]
  end

  def handle_event("search", %{"query" => query}, socket) do
    filtered_blogs =
      Enum.filter(socket.assigns.blogs, fn blog ->
        String.contains?(
          String.downcase(blog.title <> " " <> blog.excerpt),
          String.downcase(query)
        )
      end)

    socket =
      socket
      |> assign(
        search_query: query,
        filtered_blogs: filtered_blogs
      )

    {:noreply, socket}
  end
end
