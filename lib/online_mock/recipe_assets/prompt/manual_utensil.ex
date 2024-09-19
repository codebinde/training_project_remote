defmodule OnlineMock.RecipeAssets.Prompt.ManualUtensil do
  @moduledoc """
  A module to create `"Data"` for ManualUtensil prompts.
  """

  alias OnlineMock.RecipeAssets.Prompt.Manual

  @doc """
  Creates a map that can be used as `"Data"` for ManualUtensil prompts.

  `data` is used to add/override the following keys (via deep merge):

  Required:

  * `"UtensilImage"`

  Overridden:

  * `"UtensilType"`
  * `"IsParallel"`
  * `"Headline"`
  * `"Text"`

  Optional:

  * `"Identifier"`


  ## Example

      iex> OnlineMock.RecipeAssets.Prompt.ManualUtensil.data("1.0", %{"UtensilImage" => "./material/icons/insert_measuring_cup.png", "UtensilType" => 0})
      %{
        "IsParallel" => false,
        "Headline" => "deviceicon={deviceicon} deviceidentifier={deviceidentifier}",
        "Text" => "Default ManualUtensil Text",
        "UtensilType" => 0,
        "UtensilImage" => "./material/icons/insert_measuring_cup.png"
      }
  """
  def data(schema_version, data) do
    manual_utensil_data = %{
      "UtensilImage" => Map.fetch!(data, "UtensilImage"),
      "UtensilType" => Map.get(data, "UtensilType", 0)
    }

    manual_utensil_data =
      if Version.match?(schema_version <> ".0", ">= 1.0.0") do
        Map.put(
          manual_utensil_data,
          "Headline",
          Map.get(data, "Headline", "deviceicon={deviceicon} deviceidentifier={deviceidentifier}")
        )
      else
        manual_utensil_data
      end

    Manual.data(schema_version, data, "Default ManualUtensil Text")
    |> Map.merge(manual_utensil_data)
  end
end
