defmodule OnlineMock.RecipeAssets.Prompt.ManualText do
  @moduledoc """
  A module to create `"Data"` for ManualText prompts.
  """

  alias OnlineMock.RecipeAssets.Prompt.Manual
  import OnlineMock.RecipeAssets, only: [merge: 3]

  @doc """
  Creates a map that can be used as `"Data"` for ManualText prompts.

  ## SchemaVersion < 1.0

  `data` is used to add/override the following keys (via deep merge):

  Overridden:

  * `"FreeTextType"`
  * `"Text"`

  ## SchemaVersion >= 1.0

  `data` is solely used as described in `OnlineMock.RecipeAssets.Prompt.Manual.data/2`.

  ## Example

      iex> OnlineMock.RecipeAssets.Prompt.ManualText.data("0.0", %{})
      %{"FreeTextType" => 1, "Text" => "Default Text"}
      iex> OnlineMock.RecipeAssets.Prompt.ManualText.data("1.0", %{})
      %{"IsParallel" => false, "Text" => "Default Text"}
  """
  def data(schema_version, data) do
    if Version.match?(schema_version <> ".0", "< 1.0.0") do
      merge(
        %{"FreeTextType" => 1, "Text" => "Default Text"},
        data,
        ["FreeTextType", "Text"]
      )
    else
      Manual.data(schema_version, data)
    end
  end
end
