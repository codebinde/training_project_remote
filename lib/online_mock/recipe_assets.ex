defmodule OnlineMock.RecipeAssets do
  @moduledoc """
  A module for creating recipe assets.
  """

  @doc """
  Creates a recipe with default values.

  The default may be altered via `recipe`. The following keys may be used for this purpose:

    * `"MetaData"` passed to `meta_data/2` and defaults to `%{}`.
    * `"RecipeData"` passed to `recipe_data/2` and defaults to `%{}`.
    * `"SchemaVersion"` has to be a string of format MAJOR.MINOR (required)

  ## Examples

      iex> OnlineMock.RecipeAssets.recipe("id", %{"SchemaVersion" => "0.0"})
      %{
        "Id" => "id",
        "MetaData" => %{
          "Images" => [%{
            "ImageType" => 1,
            "IsPrimaryImage" => true,
            "URLs" => %{
              "Landscape" => "https://assets.tmecosys.com/images/{transformation}/generic_image",
              "Portrait" => "https://assets.tmecosys.com/images/{transformation}/generic_image",
              "Square" => "https://assets.tmecosys.com/images/{transformation}/generic_image"
            }
          }]
        },
        "RecipeData" => %{
          "FormatVersion" => 2,
          "HideInPreview" => ["RecipePreparationGroups", "RecipePrompts"],
          "RecipeInfo" => %{
            "HideInPreview" => [],
            "Name" => "Name of Recipe",
            "Nutritions" => %{
              "NutritionsArray" => [
                %{
                  "Calories" => %{"first" => "0.10", "second" => "[Cal]"},
                  "CaloriesKcal" => %{"first" => "1.01", "second" => "[Kcal]"},
                  "CaloriesKcalText" => "Energy",
                  "CaloriesText" => "Energy",
                  "Carbs" => %{"first" => "2.02", "second" => "[Carbs]"},
                  "CarbsText" => "Carb",
                  "Fat" => %{"first" => "3.03", "second" => "[Fat]"},
                  "FatText" => "Fat",
                  "Protein" => %{"first" => "4.04", "second" => "[Protein]"},
                  "ProteinText" => "Protein",
                  "QuantityFrom" => 1,
                  "QuantityTo" => "",
                  "QuantityUnit" => "portion"
                }
              ]
            },
            "SortKey" => "QQ==",
            "PreparationTime" => 0,
            "TotalTime" => 0,
            "ServingQuantity" => %{"first" => "Number", "second" => "Unit"}
          },
          "RecipeLocale" => "en",
          "RecipePrompts" => [],
          "RecipeUnitSystem" => 0,
          "TMVersions" => ["TM6"],
          "RecipePreparationGroups" => []
        },
        "SchemaVersion" => "0.0"
      }

      iex> OnlineMock.RecipeAssets.recipe("id", %{"SchemaVersion" => "1.0", "MetaData" => %{"VariantClusters" => [%{"ClusterDefaultId" => "r673161","Uid" => "29b42593-ec27-4e6e-ac5c-29a03e4ef4bb"}]}})
      %{
        "Id" => "id",
        "MetaData" => %{
          "Images" => [%{
            "ImageType" => 1,
            "IsPrimaryImage" => true,
            "URLs" => %{
              "Landscape" => "https://assets.tmecosys.com/images/{transformation}/generic_image",
              "Portrait" => "https://assets.tmecosys.com/images/{transformation}/generic_image",
              "Square" => "https://assets.tmecosys.com/images/{transformation}/generic_image"
            }
          }],
          "VariantClusters" => [%{
              "ClusterDefaultId" => "r673161",
              "ClusterType" => "portion",
              "Uid" => "29b42593-ec27-4e6e-ac5c-29a03e4ef4bb"
          }]
        },
        "RecipeData" => %{
          "FormatVersion" => 2,
          "HideInPreview" => ["RecipePreparationGroups", "RecipePrompts"],
          "RecipeInfo" => %{
            "HideInPreview" => [],
            "Name" => "Name of Recipe",
            "Nutritions" => %{
              "NutritionsArray" => [
                %{
                  "Calories" => %{"first" => "0.10", "second" => "[Cal]"},
                  "CaloriesKcal" => %{"first" => "1.01", "second" => "[Kcal]"},
                  "CaloriesKcalText" => "Energy",
                  "CaloriesText" => "Energy",
                  "Carbs" => %{"first" => "2.02", "second" => "[Carbs]"},
                  "CarbsText" => "Carb",
                  "Fat" => %{"first" => "3.03", "second" => "[Fat]"},
                  "FatText" => "Fat",
                  "Protein" => %{"first" => "4.04", "second" => "[Protein]"},
                  "ProteinText" => "Protein",
                  "QuantityFrom" => 1,
                  "QuantityTo" => "",
                  "QuantityUnit" => "portion"
                }
              ]
            },
            "SortKey" => "QQ==",
            "PreparationTime" => 0,
            "TotalTime" => 0,
            "ServingQuantity" => %{"first" => "Number", "second" => "Unit"}
          },
          "RecipeLocale" => "en",
          "RecipePrompts" => [],
          "RecipeUnitSystem" => 0,
          "TMVersions" => ["TM6"],
          "RecipePreparationGroups" => []
        },
        "SchemaVersion" => "1.0"
      }
  """
  def recipe(id, recipe) do
    schema_version = Map.fetch!(recipe, "SchemaVersion")

    %{
      "Id" => id,
      "MetaData" => meta_data(schema_version, Map.get(recipe, "MetaData", %{})),
      "RecipeData" => recipe_data(schema_version, Map.get(recipe, "RecipeData", %{})),
      "SchemaVersion" => schema_version
    }
  end

  @doc """
  Create `MetaData` to be used in a recipe with certain default values.

  The default may be altered via `meta_data`. The following keys may be used for this purpose:

  * `"Images"` passed to `images/2` and defaults to `[%{}]`.
  * `"RequiredDevices"` (SchemaVersion >= 1.0)
  * `"VariantClusters"` (SchemaVersion >= 1.0)

  ## Examples

      iex> OnlineMock.RecipeAssets.meta_data("0.0", %{})
      %{
        "Images" => [%{
          "ImageType" => 1,
          "IsPrimaryImage" => true,
          "URLs" => %{
            "Landscape" => "https://assets.tmecosys.com/images/{transformation}/generic_image",
            "Portrait" => "https://assets.tmecosys.com/images/{transformation}/generic_image",
            "Square" => "https://assets.tmecosys.com/images/{transformation}/generic_image"
          }
        }]
      }
  """
  def meta_data(schema_version, meta_data) do
    result = %{"Images" => images(schema_version, Map.get(meta_data, "Images", [%{}]))}

    if Version.match?(schema_version <> ".0", "< 1.0.0") do
      result
    else
      meta_data_v1(result, meta_data)
    end
  end

  defp meta_data_v1(result, meta_data) do
    result
    |> required_devices(meta_data)
    |> optional_devices(meta_data)
    |> variant_clusters(meta_data)
  end

  defp required_devices(result, %{"RequiredDevices" => required_devices}) do
    devices(result, "RequiredDevices", required_devices)
  end

  defp required_devices(result, _meta_data), do: result

  defp optional_devices(result, %{"OptionalDevices" => optional_devices}) do
    devices(result, "OptionalDevices", optional_devices)
  end

  defp optional_devices(result, _meta_data), do: result

  defp devices(result, tag, devices) do
    Map.put(
      result,
      tag,
      for device <- devices do
        %{
          "Identifier" => Map.fetch!(device, "Identifier"),
          "Type" => Map.fetch!(device, "Type")
        }
      end
    )
  end

  defp variant_clusters(result, %{"VariantClusters" => variant_clusters}) do
    Map.put(
      result,
      "VariantClusters",
      for cluster <- variant_clusters do
        %{
          "ClusterDefaultId" => Map.fetch!(cluster, "ClusterDefaultId"),
          "ClusterType" => Map.get(cluster, "ClusterType", "portion"),
          "Uid" => Map.fetch!(cluster, "Uid")
        }
      end
    )
  end

  defp variant_clusters(result, _meta_data), do: result

  @doc """
  Creates `RecipeData` for a recipe with default values.

  The default may be altered via `recipe_data`. The following keys may be used for this purpose:

    * `"RecipeInfo"` passed to `recipe_info/2` and defaults to `%{}`.
    * `"RecipePrompts"` passed to `recipe_prompts/2` and defaults to `[]`.
    * `"RecipeLocale"`

  ## Examples

      iex> OnlineMock.RecipeAssets.recipe_data("0.0", %{})
      %{
        "FormatVersion" => 2,
        "HideInPreview" => ["RecipePreparationGroups", "RecipePrompts"],
        "RecipeInfo" => %{
          "HideInPreview" => [],
          "Name" => "Name of Recipe",
          "Nutritions" => %{
            "NutritionsArray" => [
              %{
                "Calories" => %{"first" => "0.10", "second" => "[Cal]"},
                "CaloriesKcal" => %{"first" => "1.01", "second" => "[Kcal]"},
                "CaloriesKcalText" => "Energy",
                "CaloriesText" => "Energy",
                "Carbs" => %{"first" => "2.02", "second" => "[Carbs]"},
                "CarbsText" => "Carb",
                "Fat" => %{"first" => "3.03", "second" => "[Fat]"},
                "FatText" => "Fat",
                "Protein" => %{"first" => "4.04", "second" => "[Protein]"},
                "ProteinText" => "Protein",
                "QuantityFrom" => 1,
                "QuantityTo" => "",
                "QuantityUnit" => "portion"
              }
            ]
          },
          "SortKey" => "QQ==",
          "PreparationTime" => 0,
          "TotalTime" => 0,
          "ServingQuantity" => %{"first" => "Number", "second" => "Unit"}
        },
        "RecipeLocale" => "en",
        "RecipePrompts" => [],
        "RecipeUnitSystem" => 0,
        "TMVersions" => ["TM6"],
        "RecipePreparationGroups" => []
      }
  """
  def recipe_data(schema_version, recipe_data) do
    merge(
      %{
        "FormatVersion" => 2,
        "HideInPreview" => ["RecipePreparationGroups", "RecipePrompts"],
        "RecipeInfo" => recipe_info(schema_version, Map.get(recipe_data, "RecipeInfo", %{})),
        "RecipeLocale" => "en",
        "RecipePrompts" =>
          recipe_prompts(schema_version, Map.get(recipe_data, "RecipePrompts", [])),
        "RecipePreparationGroups" =>
          recipe_preparation_groups(
            schema_version,
            Map.get(recipe_data, "RecipePreparationGroups", [])
          ),
        "RecipeUnitSystem" => 0,
        "TMVersions" => ["TM6"]
      },
      recipe_data,
      ["RecipeLocale"]
    )
  end

  @doc """
  Creates `RecipeInfo` to be used in `RecipeData` with certain default values.

  The default may be altered via `recipe_info`. The following keys may be used for this purpose:

    * `"Name"`
    * `"ServingQuantity"`

  ## Examples

      iex> OnlineMock.RecipeAssets.recipe_info("0.0", %{})
      %{
        "HideInPreview" => [],
        "Name" => "Name of Recipe",
        "Nutritions" => %{
          "NutritionsArray" => [
            %{
              "Calories" => %{"first" => "0.10", "second" => "[Cal]"},
              "CaloriesKcal" => %{"first" => "1.01", "second" => "[Kcal]"},
              "CaloriesKcalText" => "Energy",
              "CaloriesText" => "Energy",
              "Carbs" => %{"first" => "2.02", "second" => "[Carbs]"},
              "CarbsText" => "Carb",
              "Fat" => %{"first" => "3.03", "second" => "[Fat]"},
              "FatText" => "Fat",
              "Protein" => %{"first" => "4.04", "second" => "[Protein]"},
              "ProteinText" => "Protein",
              "QuantityFrom" => 1,
              "QuantityTo" => "",
              "QuantityUnit" => "portion"
            }
          ]
        },
        "SortKey" => "QQ==",
        "PreparationTime" => 0,
        "TotalTime" => 0,
        "ServingQuantity" => %{"first" => "Number", "second" => "Unit"}
      }
  """
  def recipe_info(_schema_version, recipe_info) do
    merge(
      %{
        "HideInPreview" => [],
        "Name" => "Name of Recipe",
        "Nutritions" => %{
          "NutritionsArray" => [
            %{
              "Calories" => %{"first" => "0.10", "second" => "[Cal]"},
              "CaloriesKcal" => %{"first" => "1.01", "second" => "[Kcal]"},
              "CaloriesKcalText" => "Energy",
              "CaloriesText" => "Energy",
              "Carbs" => %{"first" => "2.02", "second" => "[Carbs]"},
              "CarbsText" => "Carb",
              "Fat" => %{"first" => "3.03", "second" => "[Fat]"},
              "FatText" => "Fat",
              "Protein" => %{"first" => "4.04", "second" => "[Protein]"},
              "ProteinText" => "Protein",
              "QuantityFrom" => 1,
              "QuantityTo" => "",
              "QuantityUnit" => "portion"
            }
          ]
        },
        "SortKey" => "QQ==",
        "PreparationTime" => 0,
        "TotalTime" => 0,
        "ServingQuantity" => %{"first" => "Number", "second" => "Unit"}
      },
      recipe_info,
      ["Name", "ServingQuantity"]
    )
  end

  @doc """
  Creates `RecipePrompts` to be used in `RecipeData`.

  `recipe_prompts` needs to be a list of maps containing at least the following keys:

    * `"Type"`
    * `"NextPrompt"`

  It calles `OnlineMock.RecipeAssets.Prompt.new/4` providing a default for `data`.

  The default may be altered via `recipe_info` using the key `"Data"`.

  ## Examples

      iex> OnlineMock.RecipeAssets.recipe_prompts("0.0", [%{"Type" => "ManualText", "NextPrompt" => -1}])
      [%{
        "Data" => %{
          "FreeTextType" => 1,
          "Text" => "Default Text"
        },
        "NextPrompt" => -1,
        "PreparationStepIndex" => 0,
        "Type" => "ManualText"
      }]
  """
  def recipe_prompts(schema_version, recipe_prompts) do
    for prompt <- recipe_prompts do
      recipe_prompt(
        schema_version,
        Map.merge(
          %{"Data" => %{}},
          prompt
        )
      )
    end
  end

  def recipe_prompt(schema_version, %{
        "Type" => type,
        "Data" => data,
        "NextPrompt" => next_prompt,
        "AlternativeTitle" => alternative_title,
        "Alternatives" => alternatives
      }) do
    Map.merge(
      %{
        "NextPrompt" => next_prompt,
        "AlternativeTitle" => alternative_title,
        "Alternatives" => alternative_prompts(schema_version, alternatives)
      },
      OnlineMock.RecipeAssets.Prompt.new(schema_version, type, data)
    )
  end

  def recipe_prompt(schema_version, %{"Type" => type, "Data" => data, "NextPrompt" => next_prompt}) do
    Map.merge(
      %{"NextPrompt" => next_prompt},
      OnlineMock.RecipeAssets.Prompt.new(schema_version, type, data)
    )
  end

  def alternative_prompts(schema_version, alternatives, prompt_results \\ [])

  def alternative_prompts(_schema_version, [], prompt_results) do
    prompt_results
  end

  def alternative_prompts(
        schema_version,
        [%{"RequiredDevices" => _} = head | tail],
        prompt_results
      ) do
    results =
      prompt_results ++
        [
          alternative_prompt(schema_version, Map.merge(%{"Data" => %{}}, head))
          |> required_devices(head)
        ]

    alternative_prompts(schema_version, tail, results)
  end

  def alternative_prompts(schema_version, [head | tail], prompt_results) do
    results =
      prompt_results ++
        [
          alternative_prompt(schema_version, Map.merge(%{"Data" => %{}}, head))
        ]

    alternative_prompts(schema_version, tail, results)
  end

  def alternative_prompt(schema_version, %{
        "Type" => type,
        "Data" => data,
        "OptionText" => option_text,
        "NextPrompt" => next_prompt
      }) do
    Map.merge(
      %{
        "OptionText" => option_text,
        "NextPrompt" => next_prompt
      },
      OnlineMock.RecipeAssets.Prompt.new(schema_version, type, data)
    )
  end

  def alternative_prompt(schema_version, %{
        "Type" => type,
        "Data" => data,
        "OptionText" => option_text,
        "NextAlternativePrompt" => next_alternative_prompt,
        "AlternativePrompts" => sub_prompts
      }) do
    Map.merge(
      %{
        "OptionText" => option_text,
        "NextAlternativePrompt" => next_alternative_prompt,
        "AlternativePrompts" => sub_prompts(schema_version, sub_prompts)
      },
      OnlineMock.RecipeAssets.Prompt.new(schema_version, type, data)
    )
  end

  def sub_prompts(schema_version, sub_prompts) do
    for sub_prompt <- sub_prompts do
      sub_prompt(
        schema_version,
        Map.merge(
          %{"Data" => %{}},
          sub_prompt
        )
      )
    end
  end

  def sub_prompt(schema_version, %{
        "Type" => type,
        "Data" => data,
        "NextAlternativePrompt" => next_alternative_prompt
      }) do
    Map.merge(
      %{"NextAlternativePrompt" => next_alternative_prompt},
      OnlineMock.RecipeAssets.Prompt.new(schema_version, type, data)
    )
  end

  def sub_prompt(schema_version, %{"Type" => type, "Data" => data, "NextPrompt" => next_prompt}) do
    Map.merge(
      %{"NextPrompt" => next_prompt},
      OnlineMock.RecipeAssets.Prompt.new(schema_version, type, data)
    )
  end

  def recipe_preparation_groups(schema_version, recipe_preparation_groups) do
    for %{"Entries" => preparation_steps, "GroupTitle" => _group_title} = preparation_group <-
          recipe_preparation_groups do
      merge(
        %{
          "Entries" => recipe_preparation_group(schema_version, preparation_steps),
          "GroupTitle" => ""
        },
        preparation_group,
        ["GroupTitle"]
      )
    end
  end

  def recipe_preparation_group(_schema_version, preparation_steps) do
    for step <- preparation_steps do
      merge(
        %{
          "StepText" => "",
          "GroupIndex" => 0,
          "PromptIndex" => -1,
          "DisplayNumber" => 1,
          "PreparationStepIndex" => 0
        },
        step,
        ["StepText", "GroupIndex", "PromptIndex", "DisplayNumber", "PreparationStepIndex"]
      )
    end
  end

  @doc """
  Creates a list of images using `image/1`.
  """
  def images(schema_version, images) do
    for image <- images, do: image(schema_version, image)
  end

  @generic_image_path "/images/{transformation}/generic_image"

  @doc """
  Creates a description of a downloadable image with certain default values.

  The defaults may be altered via the following keys:

    * `"ImageType"` defaults to `1`
    * `"ImageURLs"` defaults to a map with keys `"Landscape"`, `"Portrait"`, `"Square"` poiting to
    `assets_url("#{@generic_image_path}")`.

  ## Examples

      iex> OnlineMock.RecipeAssets.image("0.0", %{})
      %{
        "ImageType" => 1,
        "IsPrimaryImage" => true,
        "URLs" => %{
          "Landscape" => "https://assets.tmecosys.com/images/{transformation}/generic_image",
          "Portrait" => "https://assets.tmecosys.com/images/{transformation}/generic_image",
          "Square" => "https://assets.tmecosys.com/images/{transformation}/generic_image"
        }
      }
  """
  def image(schema_version, image) do
    merge(
      %{
        "ImageType" => 1,
        "IsPrimaryImage" => true,
        "URLs" =>
          for f <- ["Landscape", "Portrait", "Square"], into: %{} do
            {f, assets_url(schema_version, @generic_image_path)}
          end
      },
      image,
      ["ImageType", "IsPrimaryImage", "URLs"]
    )
  end

  @assets_url "https://assets.tmecosys.com"

  @doc """
  Creates an URL for assets.

  It merges (using `URI.merge/2`) the default URL `"#{@assets_url}"` with `url`.

  ## Examples

      iex> OnlineMock.RecipeAssets.assets_url("0.0", "/absolut/path")
      "https://assets.tmecosys.com/absolut/path"

      iex> OnlineMock.RecipeAssets.assets_url("0.0", "relativ/path")
      "https://assets.tmecosys.com/relativ/path"

      iex> OnlineMock.RecipeAssets.assets_url("0.0", "http://example.com")
      "http://example.com"
  """
  def assets_url(_schema_version, url) do
    URI.merge(@assets_url, url) |> to_string()
  end

  @doc """
  Returns the full generic image asset URL.
  """
  def generic_image_url(schema_version) do
    assets_url(schema_version, @generic_image_path)
  end

  @doc false
  def merge(source, merge, keys) do
    merge = Map.take(merge, keys)
    Map.merge(source, merge)
  end
end
