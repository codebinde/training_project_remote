defmodule OnlineMock.RecipeAssets.Prompt do
  @moduledoc """
  A module for creating prompts to be used in recipes.

  Right now the following prompts are supported:

    * CookingStationControl
    * Ingredient
    * Macro
    * ManualStream
    * ManualText
    * ManualUtensil
    * ThermomixControl
    * SensorControl
    * ThermomixTimerControl

  See the corresponding submodules of `OnlineMock.RecipeAssets.Prompt` for details.

  ## Manual Prompts

  From SchemaVersion 1.0 onwards `"Data"` is based on the same structure. For details see
  `OnlineMock.RecipeAssets.Prompt.Manual`.
  """

  @doc """
  Creates a prompt with default values.

  ## Example

      iex> OnlineMock.RecipeAssets.Prompt.new("0.0", "ManualText", %{})
      %{
        "Type" => "ManualText",
        "PreparationStepIndex" => 0,
        "Data" => %{"FreeTextType" => 1, "Text" => "Default Text"}
      }
  """
  def new(schema_version, type, data) do
    %{
      "Type" => type,
      "PreparationStepIndex" => 0,
      "Data" => data(schema_version, type, data)
    }
  end

  defp data(schema_version, type, data) do
    type_module = Module.concat(__MODULE__, type)
    type_module.data(schema_version, data)
  end
end
