defmodule OnlineMock.RecipeAssets.Prompt.ManualUtensilTest do
  use ExUnit.Case, async: true
  doctest OnlineMock.RecipeAssets.Prompt.ManualUtensil

  alias OnlineMock.RecipeAssets.Prompt.ManualUtensil

  test "correct default values for SchemaVersion 0.0" do
    assert ManualUtensil.data("0.0", %{"UtensilImage" => "./foo.png"}) == %{
             "Text" => "Default ManualUtensil Text",
             "IsParallel" => false,
             "UtensilImage" => "./foo.png",
             "UtensilType" => 0
           }
  end

  test "correct default values for SchemaVersion 1.0" do
    assert ManualUtensil.data("1.0", %{"UtensilImage" => "./bar.png"}) == %{
             "Text" => "Default ManualUtensil Text",
             "IsParallel" => false,
             "Headline" => "deviceicon={deviceicon} deviceidentifier={deviceidentifier}",
             "UtensilImage" => "./bar.png",
             "UtensilType" => 0
           }
  end

  test "merges correct values into defaults for SchemaVersion 1.0" do
    assert ManualUtensil.data("1.0", %{
             "Text" => "Hello World",
             "IsParallel" => true,
             "Headline" => "Hello World",
             "UtensilImage" => "theimage.png",
             "UtensilType" => 2
           }) == %{
             "Text" => "Hello World",
             "IsParallel" => true,
             "Headline" => "Hello World",
             "UtensilImage" => "theimage.png",
             "UtensilType" => 2
           }
  end
end
