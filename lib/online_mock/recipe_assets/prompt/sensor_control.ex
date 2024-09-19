defmodule OnlineMock.RecipeAssets.Prompt.SensorControl do
  @moduledoc """
  A module to create `"Data"` for SensorControl prompts.
  """

  import OnlineMock.RecipeAssets, only: [merge: 3]

  @doc """
  Creates a map that can be used as `"Data"` for SensorControl prompts.

  `data` is used to add/override the following keys (via deep merge):

  Required:

  * `"Identifier"`

  Overridden:

  * `"ControlSetting"`
    * `"TargetTemp"`
    * `"SensorFoodType"`
    * `"SensorCutType"`
    * `"SensorCookType"`
    * `"SensorEstimatorType"`
  * `"IsParallel"`
  * `"Headline"`
  * `"Text"`

  ## Example

      iex> OnlineMock.RecipeAssets.Prompt.SensorControl.data("1.0", %{"Identifier" => "identifier"})
      %{
        "ControlSetting" => %{
          "TargetTemp" => 60,
          "SensorFoodType" => 0,
          "SensorCutType" => 0,
          "SensorCookType" => 0,
          "SensorEstimatorType" => 0
        },
        "Identifier" => "identifier",
        "IsParallel" => false,
        "Text" => "Default Text",
        "Headline" =>
        "Default Headline: deviceicon={deviceicon} deviceidentifier={deviceidentifier}",
      }
  """
  def data(schema_version, data) do
    merge(
      %{
        "ControlSetting" =>
          control_setting(
            schema_version,
            Map.get(data, "ControlSetting", %{})
          ),
        "Identifier" => Map.fetch!(data, "Identifier"),
        "IsParallel" => false,
        "Text" => "Default Text",
        "Headline" =>
          "Default Headline: deviceicon={deviceicon} deviceidentifier={deviceidentifier}"
      },
      data,
      ["IsParallel", "Text", "Headline", "AlternativeOptionText"]
    )
  end

  defp control_setting(_schema_version, control_setting) do
    merge(
      %{
        "Id" => "m4792-v1",
        "SensorFoodType" => 0,
        "SensorCutType" => 0,
        "SensorEstimatorType" => 0
      },
      control_setting,
      [
        "TargetTemp",
        "SensorFoodType",
        "SensorCutType",
        "SensorCookType",
        "SensorEstimatorType",
        "Id"
      ]
    )
  end
end
