defmodule OnlineMock.RecipeAssets.Prompt.IngredientTest do
  use ExUnit.Case, async: true
  doctest OnlineMock.RecipeAssets.Prompt.Ingredient

  alias OnlineMock.RecipeAssets.Prompt.Ingredient

  test "merges correct values into defaults for SchemaVersion 0.0" do
    assert Ingredient.data("0.0", %{
             "GuidedIngredients" => %{"GuidedIngredientsArray" => [%{"WeighingFlag" => 1}]},
             "Identifier" => "identifier",
             "IsParallel" => true
           }) == %{
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
                   "WeighingFlag" => 1,
                   "WeighingIcons" => %{
                     "Filling" => "",
                     "Icon" => "./material/icons/without_mixing_bowl.png"
                   }
                 }
               ]
             },
             "IsParallel" => true,
             "Text" => "Default Text"
           }
  end

  test "merges correct values into defaults for SchemaVersion 1.0" do
    assert Ingredient.data("1.0", %{
             "GuidedIngredients" => %{"GuidedIngredientsArray" => [%{"WeighingFlag" => 1}]},
             "Identifier" => "identifier",
             "IsParallel" => true
           }) == %{
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
                   "WeighingFlag" => 1,
                   "WeighingIcons" => %{
                     "Filling" => "",
                     "Icon" => "./material/icons/without_mixing_bowl.png"
                   }
                 }
               ]
             },
             "Identifier" => "identifier",
             "IsParallel" => true,
             "Text" => "Default Text"
           }
  end
end
