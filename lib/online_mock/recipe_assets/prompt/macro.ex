defmodule OnlineMock.RecipeAssets.Prompt.Macro do
  @moduledoc """
  A module to create `"Data"` for Macro prompts.
  """

  @doc """
  Creates a map that can be used as `"Data"` for Macro prompts.

  `data` is used to add/override the following keys (via deep merge):

  Required:

  * `"Macro"`

  ## Example

      iex> OnlineMock.RecipeAssets.Prompt.Macro.data("0.0", %{"Macro" => "id"})
      %{"Macro" => "id"}
  """
  def data(_schema_version, data) do
    %{"Macro" => Map.fetch!(data, "Macro")}
  end
end
