defmodule LgbWeb.BlogLive do
  use LgbWeb, :live_view

  # Render function
  def render(assigns) do
    ~H"""
    <div class="flex flex-col items-center mt-8 gap-8">
      <div>
        <h1>Stories coming soon...</h1>

        <!-- Search form with phx-change to trigger search while typing -->
        <form phx-change="search" phx-submit="search">
          <input class="" type="text" name="query" value={@search_query} placeholder="Search blogs..." />
        </form>
      </div>

      <!-- Display the filtered blog posts -->
      <ul>
        <%= if length(@filtered_blogs) > 0 do %>
          <%= for blog <- @filtered_blogs do %>
            <li>
              {blog.content}
            </li>
          <% end %>
        <% else %>
          <li>No results found.</li>
        <% end %>
      </ul>
    </div>
    """
  end

  # Mount function to initialize the socket
  def mount(_params, _session, socket) do
    blogs = load_blog_files()
    # Initialize the state with all blogs and an empty search query
    socket = assign(socket,
      blogs: blogs,
      search_query: "",
      filtered_blogs: blogs
    )
    {:ok, socket}
  end

  defp load_blog_files do
    blogs_directory = "lib/lgb_web/live/blogs_live/" # Assuming your blog files are stored here

    # List of blog files (blog1.ex, blog2.ex, etc.)
    blog_files = ["blog1.ex", "blog2.ex"] # This can be dynamically generated if needed

    # Read each file and store its content
    Enum.map(blog_files, fn file ->
      content = File.read!(Path.join(blogs_directory, file))
      # Extract only the content inside the ~H""" ... """ block using regex
      extracted_content = extract_blog_content(content)

      # Strip out HTML tags from the extracted content
      plain_content = strip_html_tags(extracted_content)

      %{content: plain_content}
    end)
  end

  # Function to extract the content inside the render function
  defp extract_blog_content(file_content) do
    # Regex to extract everything inside the ~H""" ... """ block
    case Regex.run(~r/~H"""\s*(.*?)\s*"""/s, file_content) do
      [_, content] -> content
      _ -> "Content not found"
    end
  end

  # Function to strip HTML tags
  defp strip_html_tags(content) do
    # Use Regex to remove HTML tags
    content
    |> String.replace(~r/<[^>]*>/, "")
  end

  # Handle the search event and update filtered blogs
  def handle_event("search", %{"query" => query}, socket) do
    # Filter the blogs based on the search query (case-insensitive)
    filtered_blogs =
      Enum.filter(socket.assigns.blogs, fn blog ->
        String.contains?(String.downcase(blog.content), String.downcase(query))
      end)

    # Update the search query and the filtered blogs
    socket = assign(socket,
      search_query: query,
      filtered_blogs: filtered_blogs
    )

    {:noreply, socket}
  end
end
