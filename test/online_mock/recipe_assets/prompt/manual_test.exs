defmodule OnlineMock.RecipeAssets.Prompt.ManualTest do
  use ExUnit.Case, async: true
  doctest OnlineMock.RecipeAssets.Prompt.Manual

  test "has required fields with default values" do
    assert OnlineMock.RecipeAssets.Prompt.Manual.data("1.0", %{}) == %{
             "IsParallel" => false,
             "Text" => "Default Text"
           }
  end

  test "changes the default text" do
    assert OnlineMock.RecipeAssets.Prompt.Manual.data("1.0", %{}, "Another Default Text") == %{
             "IsParallel" => false,
             "Text" => "Another Default Text"
           }
  end

  test "merges data" do
    assert OnlineMock.RecipeAssets.Prompt.Manual.data(
             "1.0",
             %{
               "Identifier" => "identifier",
               "IsParallel" => true,
               "Text" => "Changed Another Default Text",
               "Headline" => "headline"
             },
             "Another Default Text"
           ) == %{
             "Identifier" => "identifier",
             "IsParallel" => true,
             "Text" => "Changed Another Default Text",
             "Headline" => "headline"
           }
  end
end
