defmodule OnlineMock.RecipeAssets.Prompt.Manual do
  @moduledoc """
  A module to create `"Data"` for Manual prompts.
  """

  import OnlineMock.RecipeAssets, only: [merge: 3]

  @doc """
  Creates a map that can be used as `"Data"` for Manual prompts.

  `data` is used to add/override the following keys (via deep merge):

  Overridden:

  * `"IsParallel"`
  * `"Text"`

  Added:

  * `"Identifier"`
  * `"Headline"`

  ## Example

      iex> OnlineMock.RecipeAssets.Prompt.Manual.data("0.0", %{})
      %{"IsParallel" => false, "Text" => "Default Text"}
  """
  def data(_schema_version, data, default_text \\ "Default Text") do
    merge(%{"IsParallel" => false, "Text" => default_text}, data, [
      "Identifier",
      "IsParallel",
      "Text",
      "Headline"
    ])
  end
end
