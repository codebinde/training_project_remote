defmodule OnlineMock.RecipeAssets.Prompt.ManualTextTest do
  use ExUnit.Case, async: true
  doctest OnlineMock.RecipeAssets.Prompt.ManualText

  alias OnlineMock.RecipeAssets.Prompt.ManualText

  test "merges correct values into defaults for SchemaVersion 0.0" do
    assert ManualText.data("0.0", %{
             "FreeTextType" => 3,
             "IsParallel" => true,
             "Text" => "merged text"
           }) == %{"FreeTextType" => 3, "Text" => "merged text"}
  end

  test "merges correct values into defaults for SchemaVersion 1.0" do
    assert ManualText.data("1.0", %{
             "FreeTextType" => 3,
             "IsParallel" => true,
             "Text" => "merged text"
           }) == %{"IsParallel" => true, "Text" => "merged text"}
  end
end
