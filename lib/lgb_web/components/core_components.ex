defmodule LgbWeb.CoreComponents do
  @moduledoc """
  Provides core UI components.

  At first glance, this module may seem daunting, but its goal is to provide
  core building blocks for your application, such as modals, tables, and
  forms. The components consist mostly of markup and are well-documented
  with doc strings and declarative assigns. You may customize and style
  them in any way you want, based on your application growth and needs.

  The default components use Tailwind CSS, a utility-first CSS framework.
  See the [Tailwind CSS documentation](https://tailwindcss.com) to learn
  how to customize them or feel free to swap in another framework altogether.

  Icons are provided by [heroicons](https://heroicons.com). See `icon/1` for usage.
  """
  use Phoenix.Component

  use Phoenix.VerifiedRoutes,
    endpoint: LgbWeb.Endpoint,
    router: LgbWeb.Router

  alias Phoenix.LiveView.JS
  import LgbWeb.Gettext

  @doc """
  Renders a modal.

  ## Examples

      <.modal id="confirm-modal">
        This is a modal.
      </.modal>

  JS commands may be passed to the `:on_cancel` to configure
  the closing/cancel event, for example:

      <.modal id="confirm" on_cancel={JS.navigate(~p"/posts")}>
        This is another modal.
      </.modal>

  """
  attr :id, :string, required: true
  attr :show, :boolean, default: false
  attr :on_cancel, JS, default: %JS{}
  slot :inner_block, required: true

  def modal(assigns) do
    ~H"""
    <div
      id={@id}
      phx-mounted={@show && show_modal(@id)}
      phx-remove={hide_modal(@id)}
      data-cancel={JS.exec(@on_cancel, "phx-remove")}
      class="relative z-50 hidden"
    >
      <div id={"#{@id}-bg"} class="bg-zinc-50/90 fixed inset-0 transition-opacity" aria-hidden="true" />
      <div
        class="fixed inset-0 overflow-y-auto"
        aria-labelledby={"#{@id}-title"}
        aria-describedby={"#{@id}-description"}
        role="dialog"
        aria-modal="true"
        tabindex="0"
      >
        <div class="flex min-h-full items-center justify-center">
          <div class="w-full max-w-3xl p-4 sm:p-6 lg:py-8">
            <.focus_wrap
              id={"#{@id}-container"}
              phx-window-keydown={JS.exec("data-cancel", to: "##{@id}")}
              phx-key="escape"
              phx-click-away={JS.exec("data-cancel", to: "##{@id}")}
              class="shadow-zinc-700/10 ring-zinc-700/10 relative hidden rounded-2xl bg-white p-14 shadow-lg ring-1 transition"
            >
              <div class="absolute top-6 right-5">
                <button
                  phx-click={JS.exec("data-cancel", to: "##{@id}")}
                  type="button"
                  class="-m-3 flex-none p-3 opacity-20 hover:opacity-40"
                  aria-label={gettext("close")}
                >
                  <.icon name="hero-x-mark-solid" class="h-5 w-5" />
                </button>
              </div>
              <div id={"#{@id}-content"}>
                {render_slot(@inner_block)}
              </div>
            </.focus_wrap>
          </div>
        </div>
      </div>
    </div>
    """
  end

  @doc """
  Renders flash notices.

  ## Examples

      <.flash kind={:info} flash={@flash} />
      <.flash kind={:info} phx-mounted={show("#flash")}>Welcome Back!</.flash>
  """
  attr :id, :string, doc: "the optional id of flash container"
  attr :flash, :map, default: %{}, doc: "the map of flash messages to display"
  attr :title, :string, default: nil
  attr :kind, :atom, values: [:info, :error], doc: "used for styling and flash lookup"
  attr :rest, :global, doc: "the arbitrary HTML attributes to add to the flash container"

  slot :inner_block, doc: "the optional inner block that renders the flash message"

  def flash(assigns) do
    assigns = assign_new(assigns, :id, fn -> "flash-#{assigns.kind}" end)

    ~H"""
    <div
      :if={msg = render_slot(@inner_block) || Phoenix.Flash.get(@flash, @kind)}
      id={@id}
      phx-click={JS.push("lv:clear-flash", value: %{key: @kind}) |> hide("##{@id}")}
      role="alert"
      class={["fixed top-2 right-2 z-50 mr-2 w-80 rounded-lg p-3 ring-1 sm:w-96", @kind == :info && "bg-emerald-50 fill-cyan-900 text-emerald-800 ring-emerald-500", @kind == :error && "bg-rose-50 fill-rose-900 text-rose-900 shadow-md ring-rose-500"]}
      {@rest}
    >
      <p :if={@title} class="flex items-center gap-1.5 text-sm font-semibold leading-6">
        <.icon :if={@kind == :info} name="hero-information-circle-mini" class="h-4 w-4" />
        <.icon :if={@kind == :error} name="hero-exclamation-circle-mini" class="h-4 w-4" />
        {@title}
      </p>
      <p class="mt-2 text-sm leading-5">{msg}</p>
      <button type="button" class="group absolute top-1 right-1 p-2" aria-label={gettext("close")}>
        <.icon name="hero-x-mark-solid" class="h-5 w-5 opacity-40 group-hover:opacity-70" />
      </button>
    </div>
    """
  end

  @doc """
  Shows the flash group with standard titles and content.

  ## Examples

      <.flash_group flash={@flash} />
  """
  attr :flash, :map, required: true, doc: "the map of flash messages"
  attr :id, :string, default: "flash-group", doc: "the optional id of flash container"

  def flash_group(assigns) do
    ~H"""
    <div id={@id}>
      <.flash kind={:info} title={gettext("Success!")} flash={@flash} />
      <.flash kind={:error} title={gettext("Error!")} flash={@flash} />
      <.flash
        id="client-error"
        kind={:error}
        title={gettext("We can't find the internet")}
        phx-disconnected={show(".phx-client-error #client-error")}
        phx-connected={hide("#client-error")}
        hidden
      >
        {gettext("Attempting to reconnect")}
        <.icon name="hero-arrow-path" class="ml-1 h-3 w-3 animate-spin" />
      </.flash>

      <.flash
        id="server-error"
        kind={:error}
        title={gettext("Something went wrong!")}
        phx-disconnected={show(".phx-server-error #server-error")}
        phx-connected={hide("#server-error")}
        hidden
      >
        {gettext("Hang in there while we get back on track")}
        <.icon name="hero-arrow-path" class="ml-1 h-3 w-3 animate-spin" />
      </.flash>
    </div>
    """
  end

  @doc """
  Renders a simple form.

  ## Examples

      <.simple_form for={@form} phx-change="validate" phx-submit="save">
        <.input field={@form[:email]} label="Email"/>
        <.input field={@form[:username]} label="Username" />
        <:actions>
          <.button>Save</.button>
        </:actions>
      </.simple_form>
  """
  attr :for, :any, required: true, doc: "the datastructure for the form"
  attr :as, :any, default: nil, doc: "the server side parameter to collect all input under"

  attr :rest, :global,
    include: ~w(autocomplete name rel action enctype method novalidate target multipart),
    doc: "the arbitrary HTML attributes to apply to the form tag"

  slot :inner_block, required: true
  slot :actions, doc: "the slot for form actions, such as a submit button"

  def simple_form(assigns) do
    ~H"""
    <.form :let={f} for={@for} as={@as} {@rest}>
      <div class="collapsible mt-10 flex flex-col space-y-8 rounded-md bg-white p-2 shadow-md">
        {render_slot(@inner_block, f)}
        <div :for={action <- @actions} class="mt-2 flex items-center justify-between gap-6">
          {render_slot(action, f)}
        </div>
      </div>
    </.form>
    """
  end

  attr :for, :any, required: true, doc: "the datastructure for the form"
  attr :as, :any, default: nil, doc: "the server side parameter to collect all input under"

  attr :rest, :global,
    include: ~w(autocomplete name rel action enctype method novalidate target multipart),
    doc: "the arbitrary HTML attributes to apply to the form tag"

  slot :inner_block, required: true
  slot :actions, doc: "the slot for form actions, such as a submit button"

  def general_chat_simple_form(assigns) do
    ~H"""
    <.form :let={f} for={@for} as={@as} {@rest}>
      <div class="flex items-center gap-2 space-y-8 rounded-md bg-white p-2 shadow-md">
        {render_slot(@inner_block, f)}
        <div :for={action <- @actions} class="mt-2 flex items-center justify-between gap-6">
          {render_slot(action, f)}
        </div>
      </div>
    </.form>
    """
  end

  attr :for, :any, required: true, doc: "the datastructure for the form"
  attr :as, :any, default: nil, doc: "the server side parameter to collect all input under"

  attr :rest, :global,
    include: ~w(autocomplete name rel action enctype method novalidate target multipart),
    doc: "the arbitrary HTML attributes to apply to the form tag"

  slot :inner_block, required: true
  slot :actions, doc: "the slot for form actions, such as a submit button"

  def profile_simple_form(assigns) do
    ~H"""
    <.form :let={f} for={@for} as={@as} {@rest}>
      <div class="collapsible flex flex-col gap-4 rounded-md bg-white p-2 shadow-md">
        {render_slot(@inner_block, f)}
        <div :for={action <- @actions} class="flex items-center justify-between gap-6">
          {render_slot(action, f)}
        </div>
      </div>
    </.form>
    """
  end

  attr :for, :any, required: true, doc: "the datastructure for the form"
  attr :as, :any, default: nil, doc: "the server side parameter to collect all input under"

  attr :rest, :global,
    include: ~w(autocomplete name rel action enctype method novalidate target multipart),
    doc: "the arbitrary HTML attributes to apply to the form tag"

  slot :inner_block, required: true
  slot :actions, doc: "the slot for form actions, such as a submit button"

  def chat_simple_form(assigns) do
    ~H"""
    <.form :let={f} for={@for} as={@as} {@rest}>
      <div class="collapsible flex flex-col rounded-md bg-white shadow-md">
        {render_slot(@inner_block, f)}
        <div :for={action <- @actions} class="mt-2 flex items-center justify-between gap-6">
          {render_slot(action, f)}
        </div>
      </div>
    </.form>
    """
  end

  @doc """
  Renders a button.

  ## Examples

      <.button>Send!</.button>
      <.button phx-click="go" class="ml-2">Send!</.button>
  """
  attr :type, :string, default: nil
  attr :class, :string, default: nil
  attr :rest, :global, include: ~w(disabled form name value)

  slot :inner_block, required: true

  def button(assigns) do
    ~H"""
    <button
      type={@type}
      class={["bg-gradient-to-r from-purple-500 to-blue-600 phx-submit-loading:opacity-75", "flex items-center gap-2 rounded-full px-6 py-2 text-white shadow-md hover:opacity-90", @class]}
      {@rest}
    >
      {render_slot(@inner_block)}
      <span class="text-lg">›</span>
    </button>
    """
  end

  @doc """
  Renders an input with label and error messages.

  A `Phoenix.HTML.FormField` may be passed as argument,
  which is used to retrieve the input name, id, and values.
  Otherwise all attributes may be passed explicitly.

  ## Types

  This function accepts all HTML input types, considering that:

    * You may also set `type="select"` to render a `<select>` tag

    * `type="checkbox"` is used exclusively to render boolean values

    * For live file uploads, see `Phoenix.Component.live_file_input/1`

  See https://developer.mozilla.org/en-US/docs/Web/HTML/Element/input
  for more information. Unsupported types, such as hidden and radio,
  are best written directly in your templates.

  ## Examples

      <.input field={@form[:email]} type="email" />
      <.input name="my-input" errors={["oh no!"]} />
  """
  attr :id, :any, default: nil
  attr :name, :any
  attr :label, :string, default: nil
  attr :value, :any

  attr :type, :string,
    default: "text",
    values: ~w(checkbox color date datetime-local email file month number password
               range search select tel text textarea time url week radio)

  attr :field, Phoenix.HTML.FormField,
    doc: "a form field struct retrieved from the form, for example: @form[:email]"

  attr :errors, :list, default: []
  attr :checked, :boolean, doc: "the checked flag for checkbox inputs"
  attr :prompt, :string, default: nil, doc: "the prompt for select inputs"
  attr :options, :list, doc: "the options to pass to Phoenix.HTML.Form.options_for_select/2"
  attr :multiple, :boolean, default: false, doc: "the multiple flag for select inputs"

  attr :rest, :global,
    include: ~w(accept autocomplete capture cols disabled form list max maxlength min minlength
                multiple pattern placeholder readonly required rows size step)

  slot :inner_block

  def input(%{field: %Phoenix.HTML.FormField{} = field} = assigns) do
    assigns
    |> assign(field: nil, id: assigns.id || field.id)
    |> assign(:errors, Enum.map(field.errors, &translate_error(&1)))
    |> assign_new(:name, fn -> if assigns.multiple, do: field.name <> "[]", else: field.name end)
    |> assign_new(:value, fn -> field.value end)
    |> input()
  end

  def input(%{type: "radio"} = assigns) do
    ~H"""
    <div phx-feedback-for={@name} class="flex items-center gap-2">
      <input
        type="radio"
        id={@id}
        name={@name}
        value={@value}
        checked={@checked}
        class="h-4 w-4 cursor-pointer border-gray-300 text-purple-600 transition-all duration-200 ease-in-out checked:shadow-[0_0_0_2px_rgba(147,51,234,0.3)] hover:ring-2 hover:ring-purple-300 hover:ring-opacity-50 hover:checked:ring-purple-400/75 focus:ring-2 focus:ring-purple-500 focus:ring-opacity-50 focus:checked:ring-purple-500/75"
        {@rest}
      />
      <.label for={@id} class="cursor-pointer select-none text-sm font-medium text-gray-700">
        {@label}
      </.label>
      <.error :for={msg <- @errors}>{msg}</.error>
    </div>
    """
  end

  def input(%{type: "checkbox"} = assigns) do
    assigns =
      assign_new(assigns, :checked, fn ->
        Phoenix.HTML.Form.normalize_value("checkbox", assigns[:value])
      end)

    ~H"""
    <div phx-feedback-for={@name}>
      <label class="flex items-center gap-4 text-sm leading-6 text-zinc-600">
        <input type="hidden" name={@name} value="false" />
        <input
          type="checkbox"
          id={@id}
          name={@name}
          value="true"
          checked={@checked}
          class="rounded border-zinc-300 text-zinc-900 focus:ring-0"
          {@rest}
        />
        {@label}
      </label>
      <.error :for={msg <- @errors}>{msg}</.error>
    </div>
    """
  end

  def input(%{type: "select"} = assigns) do
    ~H"""
    <div phx-feedback-for={@name}>
      <.label for={@id}>{@label}</.label>
      <select
        id={@id}
        name={@name}
        class="mt-2 block w-full rounded-md border border-gray-300 bg-white shadow-sm focus:border-zinc-400 focus:ring-0 sm:text-sm"
        multiple={@multiple}
        {@rest}
      >
        <option :if={@prompt} value="">{@prompt}</option>
        {Phoenix.HTML.Form.options_for_select(@options, @value)}
      </select>
      <.error :for={msg <- @errors}>{msg}</.error>
    </div>
    """
  end

  def input(%{type: "textarea"} = assigns) do
    ~H"""
    <div phx-feedback-for={@name}>
      <.label for={@id}>{@label}</.label>
      <textarea
        id={@id}
        name={@name}
        class={["mt-2 block w-full rounded-lg text-zinc-900 focus:ring-0 sm:text-sm sm:leading-6", "min-h-[6rem] phx-no-feedback:border-zinc-300 phx-no-feedback:focus:border-zinc-400", @errors == [] && "border-zinc-300 focus:border-zinc-400", @errors != [] && "border-rose-400 focus:border-rose-400"]}
        {@rest}
      ><%= Phoenix.HTML.Form.normalize_value("textarea", @value) %></textarea>
      <.error :for={msg <- @errors}>{msg}</.error>
    </div>
    """
  end

  # All other inputs text, datetime-local, url, password, etc. are handled here...
  def input(assigns) do
    ~H"""
    <div phx-feedback-for={@name} class="w-full">
      <.label for={@id}>{@label}</.label>
      <input
        type={@type}
        name={@name}
        id={@id}
        value={Phoenix.HTML.Form.normalize_value(@type, @value)}
        class={["mt-2 block w-full rounded-lg text-zinc-900 focus:ring-0 sm:text-sm sm:leading-6", "phx-no-feedback:border-zinc-300 phx-no-feedback:focus:border-zinc-400", @errors == [] && "border-zinc-300 focus:border-zinc-400", @errors != [] && "border-rose-400 focus:border-rose-400"]}
        {@rest}
      />
      <.error :for={msg <- @errors}>{msg}</.error>
    </div>
    """
  end

  @doc """
  Renders a label.
  """
  attr :for, :string, default: nil
  slot :inner_block, required: true

  def label(assigns) do
    ~H"""
    <label for={@for} class="block text-sm leading-6">
      {render_slot(@inner_block)}
    </label>
    """
  end

  @doc """
  Generates a generic error message.
  """
  slot :inner_block, required: true

  def error(assigns) do
    ~H"""
    <p class="mt-3 flex gap-3 text-sm leading-6 text-rose-600 phx-no-feedback:hidden">
      <.icon name="hero-exclamation-circle-mini" class="mt-0.5 h-5 w-5 flex-none" />
      {render_slot(@inner_block)}
    </p>
    """
  end

  @doc """
  Renders a header with title.
  """
  attr :class, :string, default: nil

  slot :inner_block, required: true
  slot :subtitle
  slot :actions

  def header(assigns) do
    ~H"""
    <header class={[@actions != [] && "flex items-center justify-between gap-6", @class]}>
      <div>
        <h1 class="text-lg font-medium leading-8">
          {render_slot(@inner_block)}
        </h1>
        <p :if={@subtitle != []} class="text-sm leading-6">
          {render_slot(@subtitle)}
        </p>
      </div>
      <div class="flex-none">{render_slot(@actions)}</div>
    </header>
    """
  end

  @doc ~S"""
  Renders a table with generic styling.

  ## Examples

      <.table id="users" rows={@users}>
        <:col :let={user} label="id"><%= user.id %></:col>
        <:col :let={user} label="username"><%= user.username %></:col>
      </.table>
  """
  attr :id, :string, required: true
  attr :rows, :list, required: true
  attr :row_id, :any, default: nil, doc: "the function for generating the row id"
  attr :row_click, :any, default: nil, doc: "the function for handling phx-click on each row"

  attr :row_item, :any,
    default: &Function.identity/1,
    doc: "the function for mapping each row before calling the :col and :action slots"

  slot :col, required: true do
    attr :label, :string
  end

  slot :action, doc: "the slot for showing user actions in the last table column"

  def table(assigns) do
    assigns =
      with %{rows: %Phoenix.LiveView.LiveStream{}} <- assigns do
        assign(assigns, row_id: assigns.row_id || fn {id, _item} -> id end)
      end

    ~H"""
    <div class="overflow-y-auto sm:overflow-visible">
      <table class="w-full">
        <thead class="text-left text-sm leading-6 text-zinc-500">
          <tr>
            <th :for={col <- @col} class="pt-2 pr-4 pb-2 pl-2 font-normal">{col[:label]}</th>

            <th :if={@action != []} class="relative p-0 pb-4">
              <span class="sr-only">{gettext("Actions")}</span>
            </th>
          </tr>
        </thead>
        <tbody
          id={@id}
          phx-update={match?(%Phoenix.LiveView.LiveStream{}, @rows) && "stream"}
          class="relative divide-y divide-zinc-100 border-t border-zinc-200 text-sm leading-6 text-zinc-700"
        >
          <tr :for={row <- @rows} id={@row_id && @row_id.(row)} class="group hover:bg-zinc-50">
            <td
              :for={{col, i} <- Enum.with_index(@col)}
              phx-click={@row_click && @row_click.(row)}
              class={["relative pl-2 ", @row_click && "hover:cursor-pointer"]}
            >
              <div class="block py-4 pr-6">
                <span class="absolute -inset-y-px right-0 -left-4 " />
                <span class={["relative", i == 0 && "font-semibold text-zinc-900"]}>
                  {render_slot(col, @row_item.(row))}
                </span>
              </div>
            </td>
            <td :if={@action != []} class="relative w-14 p-0">
              <div class="relative whitespace-nowrap py-4 text-right text-sm font-medium">
                <span class="absolute -inset-y-px -right-4 left-0 group-hover:bg-zinc-50" />
                <span
                  :for={action <- @action}
                  class="relative ml-4 font-semibold leading-6 text-zinc-900 hover:text-zinc-700"
                >
                  {render_slot(action, @row_item.(row))}
                </span>
              </div>
            </td>
          </tr>
        </tbody>
      </table>
    </div>
    """
  end

  @doc """
  Renders a data list.

  ## Examples

      <.list>
        <:item title="Title"><%= @post.title %></:item>
        <:item title="Views"><%= @post.views %></:item>
      </.list>
  """
  slot :item, required: true do
    attr :title, :string, required: true
  end

  def list(assigns) do
    ~H"""
    <div class="mt-14">
      <dl class="-my-4 divide-y divide-zinc-100">
        <div :for={item <- @item} class="flex gap-4 py-4 text-sm leading-6 sm:gap-8">
          <dt class="w-1/4 flex-none text-zinc-500">{item.title}</dt>
          <dd class="text-zinc-700">{render_slot(item)}</dd>
        </div>
      </dl>
    </div>
    """
  end

  slot :item, required: true do
    attr :title, :string, required: true
  end

  def billing_list(assigns) do
    ~H"""
    <div>
      <dl class="-my-4 divide-y divide-zinc-100">
        <div :for={item <- @item} class="flex gap-4 py-4 text-sm leading-6 sm:gap-8">
          <dt class="w-1/4 flex-none text-zinc-500">{item.title}</dt>
          <dd class="text-zinc-700">{render_slot(item)}</dd>
        </div>
      </dl>
    </div>
    """
  end

  slot :inner_block, required: true
  attr :entries, :list, default: []

  def unordered_list(assigns) do
    ~H"""
    <div>
      <ul :for={entry <- @entries}>
        <li>{render_slot(@inner_block, entry)}</li>
      </ul>
    </div>
    """
  end

  @doc """
  Renders a back navigation link.

  ## Examples

      <.back navigate={~p"/posts"}>Back to posts</.back>
  """
  attr :navigate, :any, required: true
  slot :inner_block, required: true

  def back(assigns) do
    ~H"""
    <div class="mt-16">
      <.link
        navigate={@navigate}
        class="text-sm font-semibold leading-6 text-zinc-900 hover:text-zinc-700"
      >
        <.icon name="hero-arrow-left-solid" class="h-3 w-3" />
        {render_slot(@inner_block)}
      </.link>
    </div>
    """
  end

  @doc """
  Renders a [Heroicon](https://heroicons.com).

  Heroicons come in three styles – outline, solid, and mini.
  By default, the outline style is used, but solid and mini may
  be applied by using the `-solid` and `-mini` suffix.

  You can customize the size and colors of the icons by setting
  width, height, and background color classes.

  Icons are extracted from the `deps/heroicons` directory and bundled within
  your compiled app.css by the plugin in your `assets/tailwind.config.js`.

  ## Examples

      <.icon name="hero-x-mark-solid" />
      <.icon name="hero-arrow-path" class="ml-1 w-3 h-3 animate-spin" />
  """
  attr :name, :string, required: true
  attr :class, :string, default: nil

  def icon(%{name: "hero-" <> _} = assigns) do
    ~H"""
    <span class={[@name, @class]} />
    """
  end

  ## JS Commands

  def show(js \\ %JS{}, selector) do
    JS.show(js,
      to: selector,
      transition:
        {"transition-all transform ease-out duration-300",
         "opacity-0 translate-y-4 sm:translate-y-0 sm:scale-95",
         "opacity-100 translate-y-0 sm:scale-100"}
    )
  end

  def hide(js \\ %JS{}, selector) do
    JS.hide(js,
      to: selector,
      time: 200,
      transition:
        {"transition-all transform ease-in duration-200",
         "opacity-100 translate-y-0 sm:scale-100",
         "opacity-0 translate-y-4 sm:translate-y-0 sm:scale-95"}
    )
  end

  def show_modal(js \\ %JS{}, id) when is_binary(id) do
    js
    |> JS.show(to: "##{id}")
    |> JS.show(
      to: "##{id}-bg",
      transition: {"transition-all transform ease-out duration-300", "opacity-0", "opacity-100"}
    )
    |> show("##{id}-container")
    |> JS.add_class("overflow-hidden", to: "body")
    |> JS.focus_first(to: "##{id}-content")
  end

  def hide_modal(js \\ %JS{}, id) do
    js
    |> JS.hide(
      to: "##{id}-bg",
      transition: {"transition-all transform ease-in duration-200", "opacity-100", "opacity-0"}
    )
    |> hide("##{id}-container")
    |> JS.hide(to: "##{id}", transition: {"block", "block", "hidden"})
    |> JS.remove_class("overflow-hidden", to: "body")
    |> JS.pop_focus()
  end

  @doc """
  Translates an error message using gettext.
  """
  def translate_error({msg, opts}) do
    # When using gettext, we typically pass the strings we want
    # to translate as a static argument:
    #
    #     # Translate the number of files with plural rules
    #     dngettext("errors", "1 file", "%{count} files", count)
    #
    # However the error messages in our forms and APIs are generated
    # dynamically, so we need to translate them by calling Gettext
    # with our gettext backend as first argument. Translations are
    # available in the errors.po file (as we use the "errors" domain).
    if count = opts[:count] do
      Gettext.dngettext(LgbWeb.Gettext, "errors", msg, msg, count, opts)
    else
      Gettext.dgettext(LgbWeb.Gettext, "errors", msg, opts)
    end
  end

  @doc """
  Translates the errors for a field from a keyword list of errors.
  """
  def translate_errors(errors, field) when is_list(errors) do
    for {^field, {msg, opts}} <- errors, do: translate_error({msg, opts})
  end

  @doc """
  Logged in nav
  """
  def signed_in_nav(assigns) do
    ~H"""
    <!-- Sidebar Navigation -->
    <nav class={["top-[64px] sticky flex w-full flex-row justify-around self-start border bg-white p-0 md:w-20 md:flex-col md:border-0 md:bg-transparent md:p-2", "z-10 items-center md:justify-start"]}>
      <.link navigate={~p"/profiles/current"} class="loggedinNavLinks">
        <svg
          xmlns="http://www.w3.org/2000/svg"
          fill="none"
          viewBox="0 0 24 24"
          stroke-width="1.5"
          stroke="currentColor"
          class="h-6 w-6"
        >
          <path
            stroke-linecap="round"
            stroke-linejoin="round"
            d="M17.982 18.725A7.488 7.488 0 0 0 12 15.75a7.488 7.488 0 0 0-5.982 2.975m11.963 0a9 9 0 1 0-11.963 0m11.963 0A8.966 8.966 0 0 1 12 21a8.966 8.966 0 0 1-5.982-2.275M15 9.75a3 3 0 1 1-6 0 3 3 0 0 1 6 0Z"
          />
        </svg>
        <span class="userNavText mt-1 text-xs">Profile</span>
      </.link>
      <.link class="loggedinNavLinks" navigate={~p"/profiles"}>
        <svg
          xmlns="http://www.w3.org/2000/svg"
          viewBox="0 0 20 20"
          fill="currentColor"
          class="h-5 w-5"
        >
          <path
            fill-rule="evenodd"
            d="M9 3.5a5.5 5.5 0 1 0 0 11 5.5 5.5 0 0 0 0-11ZM2 9a7 7 0 1 1 12.452 4.391l3.328 3.329a.75.75 0 1 1-1.06 1.06l-3.329-3.328A7 7 0 0 1 2 9Z"
            clip-rule="evenodd"
          />
        </svg>
        <span class="userNavText mt-1 text-xs">Search</span>
      </.link>
      <.link class="loggedinNavLinks" navigate={~p"/conversations"}>
        <svg
          xmlns="http://www.w3.org/2000/svg"
          fill="none"
          viewBox="0 0 24 24"
          stroke-width="1.5"
          stroke="currentColor"
          class="h-6 w-6"
        >
          <path
            stroke-linecap="round"
            stroke-linejoin="round"
            d="M8.625 12a.375.375 0 1 1-.75 0 .375.375 0 0 1 .75 0Zm0 0H8.25m4.125 0a.375.375 0 1 1-.75 0 .375.375 0 0 1 6 0Zm0 0h-.375M21 12c0 4.556-4.03 8.25-9 8.25a9.764 9.764 0 0 1-2.555-.337A5.972 5.972 0 0 1 5.41 20.97a5.969 5.969 0 0 1-.474-.065 4.48 4.48 0 0 0 .978-2.025c.09-.457-.133-.901-.467-1.226C3.93 16.178 3 14.189 3 12c0-4.556 4.03-8.25 9-8.25s9 3.694 9 8.25Z"
          />
        </svg>
        <span class="userNavText mt-1 text-xs">
          Inbox
        </span>
      </.link>
      <.link class="loggedinNavLinks" navigate={~p"/chat_rooms"}>
        <svg
          xmlns="http://www.w3.org/2000/svg"
          fill="none"
          viewBox="0 0 24 24"
          stroke-width="1.5"
          stroke="currentColor"
          class="h-6 w-6"
        >
          <path
            stroke-linecap="round"
            stroke-linejoin="round"
            d="M20.25 8.511c.884.284 1.5 1.128 1.5 2.097v4.286c0 1.136-.847 2.1-1.98 2.193-.34.027-.68.052-1.02.072v3.091l-3-3c-1.354 0-2.694-.055-4.02-.163a2.115 2.115 0 0 1-.825-.242m9.345-8.334a2.126 2.126 0 0 0-.476-.095 48.64 48.64 0 0 0-8.048 0c-1.131.094-1.976 1.057-1.976 2.192v4.286c0 .837.46 1.58 1.155 1.951m9.345-8.334V6.637c0-1.621-1.152-3.026-2.76-3.235A48.455 48.455 0 0 0 11.25 3c-2.115 0-4.198.137-6.24.402-1.608.209-2.76 1.614-2.76 3.235v6.226c0 1.621 1.152 3.026 2.76 3.235.577.075 1.157.14 1.74.194V21l4.155-4.155"
          />
        </svg>
        <span class="userNavText mt-1 text-xs">Chatroom</span>
      </.link>
      <.link class="loggedinNavLinks" navigate={~p"/shopping/subscriptions"}>
        <svg
          xmlns="http://www.w3.org/2000/svg"
          fill="none"
          viewBox="0 0 24 24"
          stroke-width="1.5"
          stroke="currentColor"
          class="h-6 w-6"
        >
          <path
            stroke-linecap="round"
            stroke-linejoin="round"
            d="M16.5 18.75h-9m9 0a3 3 0 0 1 3 3h-15a3 3 0 0 1 3-3m9 0v-3.375c0-.621-.503-1.125-1.125-1.125h-.871M7.5 18.75v-3.375c0-.621.504-1.125 1.125-1.125h.872m5.007 0H9.497m5.007 0a7.454 7.454 0 0 1-.982-3.172M9.497 14.25a7.454 7.454 0 0 0 .981-3.172M5.25 4.236c-.982.143-1.954.317-2.916.52A6.003 6.003 0 0 0 7.73 9.728M5.25 4.236V4.5c0 2.108.966 3.99 2.48 5.228M5.25 4.236V2.721C7.456 2.41 9.71 2.25 12 2.25c2.291 0 4.545.16 6.75.47v1.516M7.73 9.728a6.726 6.726 0 0 0 2.748 1.35m8.272-6.842V4.5c0 2.108-.966 3.99-2.48 5.228m2.48-5.492a46.32 46.32 0 0 1 2.916.52 6.003 6.003 0 0 1-5.395 4.972m0 0a6.726 6.726 0 0 1-2.749 1.35m0 0a6.772 6.772 0 0 1-3.044 0"
          />
        </svg>
        <span class="userNavText mt-1 text-xs">Premium</span>
      </.link>
      <.link class="loggedinNavLinks" href={~p"/account"}>
        <svg
          xmlns="http://www.w3.org/2000/svg"
          fill="none"
          viewBox="0 0 24 24"
          stroke-width="1.5"
          stroke="currentColor"
          class="h-6 w-6"
        >
          <path
            stroke-linecap="round"
            stroke-linejoin="round"
            d="M21 12a2.25 2.25 0 0 0-2.25-2.25H15a3 3 0 1 1-6 0H5.25A2.25 2.25 0 0 0 3 12m18 0v6a2.25 2.25 0 0 1-2.25 2.25H5.25A2.25 2.25 0 0 1 3 18v-6m18 0V9M3 12V9m18 0a2.25 2.25 0 0 0-2.25-2.25H5.25A2.25 2.25 0 0 0 3 9m18 0V6a2.25 2.25 0 0 0-2.25-2.25H5.25A2.25 2.25 0 0 0 3 6v3"
          />
        </svg>
        <span class="userNavText mt-1 text-xs">Account</span>
      </.link>
    </nav>
    """
  end

  @doc """
  Page Align
  """
  slot :inner_block, required: true
  attr :no_padding, :boolean, default: false

  def page_align(assigns) do
    ~H"""
    <div class={["flex min-h-full flex-col md:flex-row"]}>
      <!-- Sidebar Navigation -->
      <.signed_in_nav></.signed_in_nav>
      <!-- Main Content -->
      <main class={["flex-1", if(@no_padding,
    do: "p-0",
    else: "p-4")]}>
        <div class={[if(@no_padding,
    do: "h-full px-4",
    else: "mx-auto max-w-5xl")]}>
          {render_slot(@inner_block)}
        </div>
      </main>
    </div>
    """
  end

  slot :inner_block, required: true
  attr :no_padding, :boolean, default: false

  def chatrooms_page_align(assigns) do
    ~H"""
    <div class={["flex min-h-full flex-col md:flex-row"]}>
      <!-- Sidebar Navigation -->
      <.signed_in_nav></.signed_in_nav>
      <!-- Main Content -->
      <main class={["flex-1", if(@no_padding,
    do: "p-0",
    else: "p-4")]}>
        <div class={[if(@no_padding,
    do: "h-full px-4",
    else: "w-[80vw] mx-auto flex flex-col")]}>
          {render_slot(@inner_block)}
        </div>
      </main>
    </div>
    """
  end

  slot :inner_block, required: true
  attr :no_padding, :boolean, default: false

  def profile_page_align(assigns) do
    ~H"""
    <div class={["flex min-h-full flex-col md:flex-row"]}>
      <!-- Sidebar Navigation -->
      <.signed_in_nav></.signed_in_nav>
      <!-- Main Content -->
      <main class={["flex-1", if(@no_padding,
    do: "p-0",
    else: "p-4")]}>
        <div class={[if(@no_padding,
    do: "h-full px-4",
    else: "w-[80vw] mx-auto flex flex-col")]}>
          {render_slot(@inner_block)}
        </div>
      </main>
    </div>
    """
  end

  slot :inner_block, required: true
  attr :no_padding, :boolean, default: false

  def general_chatroom_page_align(assigns) do
    ~H"""
    <div class={["flex min-h-full flex-col md:flex-row"]}>
      <!-- Sidebar Navigation -->
      <.signed_in_nav></.signed_in_nav>
      <!-- Main Content -->
      <main class={["flex-1", if(@no_padding,
    do: "p-0",
    else: "p-4")]}>
        <div class={[if(@no_padding,
    do: "px-4",
    else: "w-[80vw] mx-auto flex flex-col")]}>
          {render_slot(@inner_block)}
        </div>
      </main>
    </div>
    """
  end

  slot :title
  attr :subtitle, :string
  attr :picture_url, :string, required: true
  attr :unread_messages, :integer, required: false
  slot :trailer, required: true

  def list_tile(assigns) do
    ~H"""
    <div class="rounded-lg p-3 transition-all duration-200 hover:bg-white hover:shadow-md sm:p-4">
      <div class="flex flex-col gap-3 sm:flex-row sm:items-center sm:gap-4">
        <img
          src={@picture_url}
          alt="Avatar"
          class="h-12 w-12 rounded-full object-cover ring-2 ring-gray-100 transition-all hover:ring-purple-200 sm:h-16 sm:w-16"
        />
        <div class="min-w-0 flex-1">
          <h3 class="truncate text-base font-medium text-gray-900 group-hover:text-purple-900 sm:text-lg">
            {@title}
          </h3>
          <p class="truncate text-sm text-gray-500 sm:text-base">
            {@subtitle}
          </p>
        </div>
        <div class="flex w-full items-center justify-between gap-2 sm:w-auto sm:justify-end">
          <%= if @unread_messages && @unread_messages > 0 do %>
            <div class="unread-message">
              {@unread_messages}
            </div>
          <% end %>
          {render_slot(@trailer)}
        </div>
      </div>
    </div>
    """
  end

  @doc """
  Card component
  """

  attr :class, :string, default: nil, doc: "Custom CSS classes to be added to the card."
  attr :no_background, :boolean, default: true
  slot :inner_block, required: true

  def card(assigns) do
    ~H"""
    <div class={["rounded-lg", @class, if(@no_background, do: "border bg-white p-2 ", else: "")]}>
      {render_slot(@inner_block)}
    </div>
    """
  end

  @doc """
  Non logged in navbar
  """
  slot :inner_block, required: true

  def non_logged_in_nav(assigns) do
    ~H"""
    <!-- Hero Section Container -->
    <div class="relative min-h-screen">
      <!-- Navigation Bar -->
      <nav class="sticky top-0 z-10 flex px-4 py-4 backdrop-blur-md">
        <div class="container mx-auto flex flex-col items-center justify-between gap-4 md:flex-row md:gap-0">
          <!-- Logo -->
          <div class="flex items-center space-x-2">
            <span class="text-xl font-bold">
              <.link navigate={~p"/"}>
                <h1 class="font-sans bg-gradient-to-r from-purple-600 to-blue-600 bg-clip-text text-3xl text-transparent">
                  bi⏾bi
                </h1>
              </.link>
            </span>
          </div>
          
    <!-- Navigation Links -->
          <div class="menu cursor-pointer" onclick="expandNavigation()">
            <svg
              xmlns="http://www.w3.org/2000/svg"
              fill="none"
              viewBox="0 0 24 24"
              stroke-width="1.5"
              stroke="currentColor"
              class="size-6"
            >
              <path stroke-linecap="round" stroke-linejoin="round" d="M3.75 9h16.5m-16.5 6.75h16.5" />
            </svg>
          </div>
          <div class="navs fixed top-0 left-0 h-screen w-0 overflow-x-hidden bg-white shadow-lg sm:static sm:h-max sm:w-full sm:w-min sm:gap-0 sm:rounded-full sm:px-6 sm:py-3">
            <div class="flex flex-col sm:flex-row sm:p-0">
              <button
                class="bg-colorPrimary m-4 w-max rounded-3xl px-4 py-1 shadow-lg sm:hidden"
                onclick="closeNavigation()"
              >
                esc
              </button>
              <a href="/products" class="loggedOutNavbarText">
                Products
              </a>
              <a href="/features" class="loggedOutNavbarText">
                Features
              </a>
              <a href="/blogs" class="loggedOutNavbarText">
                Blogs
              </a>
              <a href="/community" class="loggedOutNavbarText">
                Community
              </a>
              <a href="/pricing" class="loggedOutNavbarText">
                Pricing
              </a>
            </div>
          </div>
          
    <!-- Login Button
          <.link
            class="hidden"
            navigate={~p"/users/log_in"}
            class="text-gray-600 hover:text-gray-900 font-medium"
          >
            Log in
          </.link>
    -->
          <div />
        </div>
      </nav>

      {render_slot(@inner_block)}
    </div>
    """
  end

  @doc """
  name activity
  """

  attr :show, :boolean, default: false
  attr :primary, :boolean, default: true

  def name_with_online_activity(assigns) do
    user = assigns.profile.user

    LgbWeb.Presence.find_user("users", user.id)

    found_user =
      if LgbWeb.Presence.find_user("users", user.id) do
        true
      else
        false
      end

    assigns = assign(assigns, :found_user, found_user)

    ~H"""
    <div class="flex items-center gap-2 rounded-lg p-2 transition-all">
      <div class="flex items-center gap-2">
        <div :if={@found_user} class="flex">
          <div class="h-2 w-2 rounded-full bg-green-400"></div>
          <div class="absolute h-2 w-2 animate-ping rounded-full bg-green-400"></div>
        </div>
        <div class={["text-lg font-medium", if(@primary, do: "text-white", else: "text-black")]}>
          {@profile.handle}
        </div>
        <div
          :if={!@found_user and @profile.user.last_login_at != nil and @show}
          class="text-xs font-light text-gray-400"
        >
          <%= cond do %>
            <% LgbWeb.UserPresence.within_minutes?(@profile.user.last_login_at, 60) -> %>
              {LgbWeb.UserPresence.format_hours_ago(@profile.user.last_login_at)}
            <% LgbWeb.UserPresence.within_hours?(@profile.user.last_login_at, 24) -> %>
              Last active yesterday
            <% true -> %>
              Last active {Calendar.strftime(
                @profile.user.last_login_at || DateTime.utc_now(),
                "%b %d"
              )}
          <% end %>
        </div>
      </div>
    </div>
    """
  end

  attr :prefix_id, :string, default: ""

  def profile_preview(assigns) do
    ~H"""
    <.card
      no_background={false}
      class="m-1 border-b-2 border-transparent transition-all duration-200 hover:border-blue-300"
    >
      <div class="relative">
        <.live_component
          id={@prefix_id <> "#{@profile.id}"}
          module={LgbWeb.Components.Carousel}
          uploaded_files={@profile.profile_pictures}
          length={1}
        />
        <div class="from-black/50 absolute right-0 bottom-0 left-0 rounded-b-lg bg-gradient-to-t to-transparent p-4">
          <.link
            navigate={~p"/profiles/#{@profile.id}"}
            class="text-lg font-semibold text-white transition-colors hover:text-gray-100"
          >
            <.name_with_online_activity profile={@profile} />
          </.link>
        </div>
      </div>

      <div class="space-y-2 p-4">
        <div class="grid grid-cols-2 gap-3 text-sm">
          <div class="flex items-center gap-2 text-gray-600">
            <.icon name="hero-rectangle-stack" class="h-4 w-4" />
            <span>{Lgb.Profiles.display_height(@profile.height_cm)}</span>
          </div>
          <div class="flex items-center gap-2 text-gray-600">
            <.icon name="hero-scale-solid" class="h-4 w-4" />
            <span>{Lgb.Profiles.display_weight(@profile.weight_lb)}</span>
          </div>
          <div class="flex items-center gap-2 text-gray-600">
            <.icon name="hero-cake-solid" class="h-4 w-4" />
            <span>{@profile.age} years</span>
          </div>
          <div class="flex items-center gap-2 text-gray-600">
            <.icon name="hero-map-pin-solid" class="h-4 w-4" />
            <span>{Lgb.Profiles.display_distance(@profile.distance)} miles away</span>
          </div>
        </div>
      </div>
    </.card>
    """
  end
end
