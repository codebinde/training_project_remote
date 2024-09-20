defmodule OnlineMock.RecipeAssets.Prompt.ThermomixTimerControl do
  @moduledoc """
  A module to create `"Data"` for ThermomixTimerControl prompts.
  """

  import OnlineMock.RecipeAssets, only: [merge: 3]

  @doc """
  Creates a map that can be used as `"Data"` for ThermomixTimerControl prompts.

  `data` is used to add/override the following keys (via deep merge):

  Required:

  * `"Identifier"`

  Overridden:

  * `"ControlSetting"`
    * `"TotalSeconds"`
  * `"IsParallel"`
  * `"Headline"`
  * `"Text"`

  ## Example

      iex> OnlineMock.RecipeAssets.Prompt.ThermomixTimerControl.data("1.0", %{"Identifier" => "identifier"})
      %{
        "ControlSetting" => %{
          "TotalSeconds" => 0
        },
        "Identifier" => "identifier",
        "UtensilImage" => UtensilImage",
        "UtensilType" => "UtensilType",
        "IsParallel" => false,
        "Text" => "Default Text",
        "Headline" =>
        "Default Headline: deviceicon={deviceicon} deviceidentifier={deviceidentifier}",
      }
  """
  def data(schema_version, data) do
    merge(
      %{
        "ControlSetting" =>
          control_setting(
            schema_version,
            Map.get(data, "ControlSetting", %{})
          ),
        "Identifier" => Map.fetch!(data, "Identifier"),
        "UtensilImage" => Map.fetch!(data, "UtensilImage"),
        "UtensilType" => Map.get(data, "UtensilType", 0),
        "IsParallel" => false,
        "Text" => "Default Text",
        "Headline" =>
          "Default Headline: deviceicon={deviceicon} deviceidentifier={deviceidentifier}"
      },
      data,
      ["IsParallel", "Text", "Headline", "AlternativeOptionText"]
    )
  end

  defp control_setting(_schema_version, control_setting) do
    merge(
      %{
        "TotalSeconds" => 0
      },
      control_setting,
      [
        "TotalSeconds"
      ]
    )
  end
end
