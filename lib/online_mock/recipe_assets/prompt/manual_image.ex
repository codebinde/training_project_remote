defmodule OnlineMock.RecipeAssets.Prompt.ManualImage do
  @moduledoc """
  A module to create `"Data"` for ManualImage prompts.
  """

  import OnlineMock.RecipeAssets, only: [images: 2]
  alias OnlineMock.RecipeAssets.Prompt.Manual

  @doc """
  Creates a map that can be used as `"Data"` for ManualImage prompts.

  `data` is used to add/override the following keys (via deep merge):

  Overridden:

  * `"Text"`
  * `"Image"`
  * `"IsParallel"`
  * `"Headline"`
  * `"FullViewImages"`
  * `"Identifier"`
  * `"Headline"`

  ## Example

      iex> OnlineMock.RecipeAssets.Prompt.ManualImage.data("1.0", %{})
      %{
        "FullViewImages" => [%{
          "ImageType" => 1,
          "IsPrimaryImage" => true,
          "URLs" => %{
            "Landscape" => "https://assets.tmecosys.com/images/{transformation}/generic_image",
            "Portrait" => "https://assets.tmecosys.com/images/{transformation}/generic_image",
            "Square" => "https://assets.tmecosys.com/images/{transformation}/generic_image"
          }
        }],
        "Headline" => "deviceicon={deviceicon} deviceidentifier={deviceidentifier}",
        "Image" => [%{
          "ImageType" => 1,
          "IsPrimaryImage" => true,
          "URLs" => %{
            "Landscape" => "https://assets.tmecosys.com/images/{transformation}/generic_image",
            "Portrait" => "https://assets.tmecosys.com/images/{transformation}/generic_image",
            "Square" => "https://assets.tmecosys.com/images/{transformation}/generic_image"
          }
        }],
        "IsParallel" => false,
        "Text" => "Default ManualImage Text"
      }
  """
  def data(schema_version, data) do
    manual_image_data = %{
      "Image" => images(schema_version, Map.get(data, "Image", [%{}])),
      "FullViewImages" => full_view_images(schema_version, data)
    }

    manual_image_data =
      if Version.match?(schema_version <> ".0", ">= 1.0.0") do
        Map.put(
          manual_image_data,
          "Headline",
          Map.get(data, "Headline", "deviceicon={deviceicon} deviceidentifier={deviceidentifier}")
        )
      else
        manual_image_data
      end

    Manual.data(schema_version, data, "Default ManualImage Text")
    |> Map.merge(manual_image_data)
  end

  defp full_view_images(schema_version, data) do
    if Version.match?(schema_version <> ".0", ">= 1.0.0") do
      images(schema_version, Map.get(data, "FullViewImages", [%{}]))
    else
      Map.get(data, "FullViewImages", [])
    end
  end
end
