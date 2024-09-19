defmodule OnlineMock.RecipeAssets.Prompt.CookingStationControl do
  @moduledoc """
  A module to create `"Data"` for CookingStationControl prompts.
  """

  import OnlineMock.RecipeAssets, only: [merge: 3]

  @doc """
  Creates a map that can be used as `"Data"` for CookingStationControl prompts.

  `data` is used to add/override the following keys (via deep merge):

  Required:

  * `"Identifier"`

  Overridden:

  * `"ControlSetting"`
    * `"Speed10"`
    * `"Temp"`
    * `"TotalSeconds"`
  * `"IsParallel"`
  * `"Headline"`

  ## Example

      iex> OnlineMock.RecipeAssets.Prompt.CookingStationControl.data("1.0", %{"Identifier" => "identifier"})
      %{
        "ControlSetting" => %{
          "Speed10" => 0,
          "Temp" => 0,
          "TimeType" => 1,
          "TotalSeconds" => 0
        },
        "Identifier" => "identifier",
        "IsParallel" => false,
        "Headline" =>
        "Default Headline: deviceicon={deviceicon} deviceidentifier={deviceidentifier}",
      }
  """
  def data(schema_version, data) do
    merge(
      %{
        "ControlSetting" => control_setting(schema_version, Map.get(data, "ControlSetting", %{})),
        "Identifier" => Map.fetch!(data, "Identifier"),
        "IsParallel" => false,
        "Headline" =>
          "Default Headline: deviceicon={deviceicon} deviceidentifier={deviceidentifier}"
      },
      data,
      ["IsParallel", "Headline"]
    )
  end

  defp control_setting(_schema_version, control_setting) do
    merge(
      %{
        "Speed10" => 0,
        "Temp" => 0,
        "TimeType" => 1,
        "TotalSeconds" => 0
      },
      control_setting,
      ["Speed10", "Temp", "TotalSeconds"]
    )
  end
end
