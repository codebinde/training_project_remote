defmodule OnlineMock.RecipeAssets.Prompt.Ingredient do
  @moduledoc """
  A module to create `"Data"` for Ingredient prompts.
  """

  import OnlineMock.RecipeAssets, only: [merge: 3]

  @doc """
  Creates a map that can be used as `"Data"` for Ingredient prompts.

  `data` is used to add/override the following keys (via deep merge):

  Overridden:

  * `"GuidedIngredients"`
    * `"GuidedIngredientsArray"`
      * `"WeighingFlag"`
  * `"IsParallel"`

  Added:

  * `"Identifier"` (SchemaVersion >= 1.0)

  ## Example

      iex> OnlineMock.RecipeAssets.Prompt.Ingredient.data("0.0", %{})
      %{
        "GuidedIngredients" => %{
          "GuidedIngredientsArray" => []
        },
        "IsParallel" => false,
        "Text" => "Default Text"
      }
      iex> OnlineMock.RecipeAssets.Prompt.Ingredient.data("0.0", %{"GuidedIngredients" => %{"GuidedIngredientsArray" => [%{}]}})
      %{
        "GuidedIngredients" => %{
          "GuidedIngredientsArray" => [
               %{
                 "GuidedIngredientInformation" => %{
                   "IngredientInformationWithExplanationOptional" => %{
                     "Explanation" => "Explanation",
                     "IngredientInformationWithExplanation" => %{
                       "AmountFrom" => "AmountFrom",
                       "AmountFromValue" => 0,
                       "AmountTo" => "AmountTo",
                       "AmountToValue" => 0,
                       "IngredientId" => 0,
                       "IngredientNotation" => "IngredientNotation",
                       "IsAlternative" => false,
                       "Unit" => "Unit"
                     }
                   },
                   "Optional" => false
                 },
                 "WeighingFlag" => 0,
                 "WeighingIcons" => %{
                   "Filling" => "",
                   "Icon" => "./material/icons/without_mixing_bowl.png"
                 }
               }
             ]
        },
        "IsParallel" => false,
        "Text" => "Default Text"
      }
  """
  def data(schema_version, data) do
    merge(
      %{
        "GuidedIngredients" => %{
          "GuidedIngredientsArray" =>
            guided_ingredients_array(
              schema_version,
              get_in(data, ["GuidedIngredients", "GuidedIngredientsArray"])
            )
        },
        "IsParallel" => false,
        "Text" => "Default Text"
      },
      data,
      to_be_merged_data(schema_version)
    )
  end

  defp to_be_merged_data(schema_version) do
    to_be_merged = ["IsParallel"]

    if Version.match?(schema_version <> ".0", "< 1.0.0") do
      to_be_merged
    else
      ["Identifier" | to_be_merged]
    end
  end

  defp guided_ingredients_array(_schema_version, nil), do: []

  defp guided_ingredients_array(_schema_version, entries) do
    for entry <- entries do
      %{
        "GuidedIngredientInformation" => guided_ingredient_information(),
        "WeighingFlag" => Map.get(entry, "WeighingFlag", 0),
        "WeighingIcons" => weighing_icons()
      }
    end
  end

  defp guided_ingredient_information do
    %{
      "IngredientInformationWithExplanationOptional" => %{
        "Explanation" => "Explanation",
        "IngredientInformationWithExplanation" => %{
          "AmountFrom" => "AmountFrom",
          "AmountFromValue" => 0,
          "AmountTo" => "AmountTo",
          "AmountToValue" => 0,
          "IngredientId" => 0,
          "IngredientNotation" => "IngredientNotation",
          "IsAlternative" => false,
          "Unit" => "Unit"
        }
      },
      "Optional" => false
    }
  end

  defp weighing_icons do
    %{"Filling" => "", "Icon" => "./material/icons/without_mixing_bowl.png"}
  end
end
