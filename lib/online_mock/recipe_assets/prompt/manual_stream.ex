defmodule OnlineMock.RecipeAssets.Prompt.ManualStream do
  @moduledoc """
  A module to create `"Data"` for ManualStream prompts.
  """

  alias OnlineMock.RecipeAssets.Prompt.Manual
  import OnlineMock.RecipeAssets, only: [image: 2, assets_url: 2]

  @doc """
  Creates a map that can be used as `"Data"` for ManualStream prompts.

  `data` is used to add/override the following keys (via deep merge):

  Override:

  * `"Stream"`
    * `"StreamURL"` (via `OnlineMock.RecipeAssets.assets_url/2`)

  ## Example

      iex> OnlineMock.RecipeAssets.Prompt.ManualStream.data("1.0", %{})
      %{
        "Image" => [
          %{
            "ImageType" => 6,
            "IsPrimaryImage" => true,
            "URLs" => %{
              "Landscape" => "https://assets.tmecosys.com/images/{transformation}/generic_image",
              "Portrait" => "https://assets.tmecosys.com/images/{transformation}/generic_image",
              "Square" => "https://assets.tmecosys.com/images/{transformation}/generic_image"
            }
          }
        ],
        "Stream" => %{
          "Preview" => [
            %{
              "ImageType" => 6,
              "IsPrimaryImage" => true,
              "URLs" => %{
                "Landscape" => "https://assets.tmecosys.com/images/{transformation}/generic_image",
                "Portrait" => "https://assets.tmecosys.com/images/{transformation}/generic_image",
                "Square" => "https://assets.tmecosys.com/images/{transformation}/generic_image"
              }
            }
          ],
          "StreamURL" => "https://assets.tmecosys.com/stream/multiSegmentStream/multiSegmentStream"
        },
        "Text" => "Tap on play to start the video",
        "IsParallel" => false
      }
  """
  def data(schema_version, data) do
    additional_data = %{
      "Image" => [image(schema_version, %{"ImageType" => 6})],
      "Stream" => stream(schema_version, Map.get(data, "Stream", %{}))
    }

    Manual.data(schema_version, data, "Tap on play to start the video")
    |> Map.merge(additional_data)
  end

  defp stream(schema_version, stream) do
    stream_url = Map.get(stream, "StreamURL", "/stream/multiSegmentStream/multiSegmentStream")

    %{
      "Preview" => [image(schema_version, %{"ImageType" => 6})],
      "StreamURL" => assets_url(schema_version, stream_url)
    }
  end
end
