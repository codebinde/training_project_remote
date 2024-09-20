defmodule OnlineMock.RecipeAssets.Prompt.ThermomixControlTest do
  use ExUnit.Case, async: true
  doctest OnlineMock.RecipeAssets.Prompt.ThermomixControl

  alias OnlineMock.RecipeAssets.Prompt.ThermomixControl

  test "merges values into defaults" do
    assert ThermomixControl.data("0.0", %{
             "ControlSetting" => %{"Speed10" => 1, "Temp" => 1, "TotalSeconds" => 1}
           }) == %{
             "ControlSetting" => %{
               "MotorFunction" => 2,
               "Rotation" => 1,
               "Speed10" => 1,
               "Temp" => 1,
               "TimeType" => 1,
               "TotalSeconds" => 1,
               "TurboImpulseTime" => 0,
               "TurboPulseCount" => 0
             },
             "StepTextRunning" => "Default StepTextRunning",
             "Text" => "Default Text"
           }
  end
end
