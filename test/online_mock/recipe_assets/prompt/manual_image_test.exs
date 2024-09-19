defmodule OnlineMock.RecipeAssets.Prompt.ManualImageTest do
  use ExUnit.Case, async: true
  doctest OnlineMock.RecipeAssets.Prompt.ManualImage

  alias OnlineMock.RecipeAssets.Prompt.ManualImage

  test "merges correct values into defaults for SchemaVersion 1.0" do
    assert ManualImage.data("1.0", %{
             "Text" => "Hello World",
             "IsParallel" => true,
             "Headline" => "Hello World",
             "FullViewImages" => [
               %{
                 "ImageType" => 1,
                 "IsPrimaryImage" => true,
                 "URLs" => %{
                   "Landscape" =>
                     "https://assets.tmecosys.com/images/{transformation}/generic_image",
                   "Portrait" =>
                     "https://assets.tmecosys.com/images/{transformation}/generic_image",
                   "Square" => "https://assets.tmecosys.com/images/{transformation}/generic_image"
                 }
               }
             ],
             "Image" => [
               %{
                 "ImageType" => 1,
                 "IsPrimaryImage" => true,
                 "URLs" => %{
                   "Landscape" =>
                     "https://assets.tmecosys.com/images/{transformation}/generic_image",
                   "Portrait" =>
                     "https://assets.tmecosys.com/images/{transformation}/generic_image",
                   "Square" => "https://assets.tmecosys.com/images/{transformation}/generic_image"
                 }
               }
             ]
           }) == %{
             "Headline" => "Hello World",
             "IsParallel" => true,
             "Text" => "Hello World",
             "FullViewImages" => [
               %{
                 "ImageType" => 1,
                 "IsPrimaryImage" => true,
                 "URLs" => %{
                   "Landscape" =>
                     "https://assets.tmecosys.com/images/{transformation}/generic_image",
                   "Portrait" =>
                     "https://assets.tmecosys.com/images/{transformation}/generic_image",
                   "Square" => "https://assets.tmecosys.com/images/{transformation}/generic_image"
                 }
               }
             ],
             "Image" => [
               %{
                 "ImageType" => 1,
                 "IsPrimaryImage" => true,
                 "URLs" => %{
                   "Landscape" =>
                     "https://assets.tmecosys.com/images/{transformation}/generic_image",
                   "Portrait" =>
                     "https://assets.tmecosys.com/images/{transformation}/generic_image",
                   "Square" => "https://assets.tmecosys.com/images/{transformation}/generic_image"
                 }
               }
             ]
           }
  end
end
