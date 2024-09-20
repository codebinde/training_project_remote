defmodule OnlineMock.RecipeAssets.Prompt.ThermomixControl do
  @moduledoc """
  A module to create `"Data"` for ThermomixControl prompts.
  """

  import OnlineMock.RecipeAssets, only: [merge: 3]

  @doc """
  Creates a map that can be used as `"Data"` for ThermomixControl prompts.

  `data` is used to add/override the following keys (via deep merge):

  Overridden:

  * `"ControlSetting"`
    * `"Speed10"`
    * `"Temp"`
    * `"TotalSeconds"`

  ## Example

      iex> OnlineMock.RecipeAssets.Prompt.ThermomixControl.data("0.0", %{})
      %{
        "ControlSetting" => %{
          "MotorFunction" => 2,
          "Rotation" => 1,
          "Speed10" => 0,
          "Temp" => 0,
          "TimeType" => 1,
          "TotalSeconds" => 0,
          "TurboImpulseTime" => 0,
          "TurboPulseCount" => 0
        },
        "StepTextRunning" => "Default StepTextRunning",
        "Text" => "Default Text"
      }
  """
  def data(schema_version, data) do
    %{
      "ControlSetting" => control_setting(schema_version, Map.get(data, "ControlSetting", %{})),
      "StepTextRunning" => "Default StepTextRunning",
      "Text" => "Default Text"
    }
  end

  defp control_setting(_schema_version, control_setting) do
    merge(
      %{
        "MotorFunction" => 2,
        "Rotation" => 1,
        "Speed10" => 0,
        "Temp" => 0,
        "TimeType" => 1,
        "TotalSeconds" => 0,
        "TurboImpulseTime" => 0,
        "TurboPulseCount" => 0
      },
      control_setting,
      ["Speed10", "Temp", "TotalSeconds"]
    )
  end
end
