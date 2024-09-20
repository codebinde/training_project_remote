defmodule OnlineMock.RecipeAssets.Prompt.ManualStreamTest do
  use ExUnit.Case, async: true
  doctest OnlineMock.RecipeAssets.Prompt.ManualStream

  alias OnlineMock.RecipeAssets.Prompt.ManualStream

  test "merges values into defaults" do
    assert ManualStream.data("0.0", %{"Stream" => %{"StreamURL" => "https://some.other.url"}}) ==
             %{
               "Image" => [
                 %{
                   "ImageType" => 6,
                   "IsPrimaryImage" => true,
                   "URLs" => %{
                     "Landscape" =>
                       "https://assets.tmecosys.com/images/{transformation}/generic_image",
                     "Portrait" =>
                       "https://assets.tmecosys.com/images/{transformation}/generic_image",
                     "Square" =>
                       "https://assets.tmecosys.com/images/{transformation}/generic_image"
                   }
                 }
               ],
               "Stream" => %{
                 "Preview" => [
                   %{
                     "ImageType" => 6,
                     "IsPrimaryImage" => true,
                     "URLs" => %{
                       "Landscape" =>
                         "https://assets.tmecosys.com/images/{transformation}/generic_image",
                       "Portrait" =>
                         "https://assets.tmecosys.com/images/{transformation}/generic_image",
                       "Square" =>
                         "https://assets.tmecosys.com/images/{transformation}/generic_image"
                     }
                   }
                 ],
                 "StreamURL" => "https://some.other.url"
               },
               "Text" => "Tap on play to start the video",
               "IsParallel" => false
             }
  end
end
