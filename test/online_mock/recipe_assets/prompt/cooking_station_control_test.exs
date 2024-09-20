defmodule OnlineMock.RecipeAssets.Prompt.CookingStationControlTest do
  use ExUnit.Case, async: true
  doctest OnlineMock.RecipeAssets.Prompt.CookingStationControl

  alias OnlineMock.RecipeAssets.Prompt.CookingStationControl

  test "merges values into defaults" do
    assert CookingStationControl.data("1.0", %{
             "Identifier" => "identifier",
             "ControlSetting" => %{"Speed10" => 1, "Temp" => 1, "TotalSeconds" => 1},
             "IsParallel" => true,
             "Headline" => "changed headline"
           }) == %{
             "ControlSetting" => %{
               "Speed10" => 1,
               "Temp" => 1,
               "TimeType" => 1,
               "TotalSeconds" => 1
             },
             "Identifier" => "identifier",
             "IsParallel" => true,
             "Headline" => "changed headline"
           }
  end
end
