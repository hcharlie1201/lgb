defmodule LgbWeb.SupHTML do
  @moduledoc """
  This module contains pages rendered by PageController.

  See the `page_html` directory for all templates available.
  """
  use LgbWeb, :html

  # def something(assigns) do
  #   ~H"""
  #   <div>some bullcrap</div>
  #   """
  # end
  embed_templates "sup_html/*"
end
