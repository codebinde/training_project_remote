defmodule OnlineMock.RecipeAssetsTest do
  use ExUnit.Case, async: true
  doctest OnlineMock.RecipeAssets

  alias OnlineMock.RecipeAssets

  test ~s(merges correct values into "MetaData" for SchemaVersion 0.0) do
    assert RecipeAssets.meta_data("0.0", %{
             "RequiredDevices" => [%{"Identifier" => "identifier", "Type" => "type"}]
           }) == %{
             "Images" => [
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

  test ~s(merges correct values for "RequiredDevices" into "MetaData" for SchemaVersion 1.0) do
    assert RecipeAssets.meta_data("1.0", %{
             "RequiredDevices" => [%{"Identifier" => "identifier", "Type" => "type"}]
           }) == %{
             "Images" => [
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
             "RequiredDevices" => [%{"Identifier" => "identifier", "Type" => "type"}]
           }
  end

  test ~s(merges correct values for "OptionalDevices" into "MetaData" for SchemaVersion 1.0) do
    assert RecipeAssets.meta_data("1.0", %{
             "OptionalDevices" => [%{"Identifier" => "#42", "Type" => "sensor"}]
           }) == %{
             "Images" => [
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
             "OptionalDevices" => [%{"Identifier" => "#42", "Type" => "sensor"}]
           }
  end

  test ~s(merges correct values if both "OptionalDevices" and "RequiredDevices" are present into "MetaData" for SchemaVersion 1.0) do
    assert RecipeAssets.meta_data("1.0", %{
             "OptionalDevices" => [%{"Identifier" => "#42", "Type" => "sensor"}],
             "RequiredDevices" => [%{"Identifier" => "identifier", "Type" => "type"}]
           }) == %{
             "Images" => [
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
             "RequiredDevices" => [%{"Identifier" => "identifier", "Type" => "type"}],
             "OptionalDevices" => [%{"Identifier" => "#42", "Type" => "sensor"}]
           }
  end

  test ~s(checks correct parsing of prompts with alternative prompts) do
    assert RecipeAssets.recipe_prompts(
             "1.0",
             [
               %{"Type" => "ManualText", "NextPrompt" => 1},
               %{
                 "Type" => "ManualText",
                 "NextPrompt" => 2,
                 "AlternativeTitle" => "These are alternatives",
                 "Alternatives" => [
                   %{
                     "Type" => "ManualText",
                     "OptionText" => "This is an option text",
                     "NextPrompt" => 3
                   },
                   %{
                     "Type" => "ManualText",
                     "OptionText" => "This is another option text",
                     "NextAlternativePrompt" => 4,
                     "AlternativePrompts" => [
                       %{
                         "Type" => "ManualText",
                         "NextAlternativePrompt" => 5
                       },
                       %{
                         "Type" => "ManualText",
                         "NextPrompt" => 6
                       }
                     ]
                   }
                 ]
               }
             ]
           ) == [
             %{
               "Data" => %{
                 "IsParallel" => false,
                 "Text" => "Default Text"
               },
               "NextPrompt" => 1,
               "PreparationStepIndex" => 0,
               "Type" => "ManualText"
             },
             %{
               "Data" => %{
                 "IsParallel" => false,
                 "Text" => "Default Text"
               },
               "PreparationStepIndex" => 0,
               "Type" => "ManualText",
               "NextPrompt" => 2,
               "AlternativeTitle" => "These are alternatives",
               "Alternatives" => [
                 %{
                   "Data" => %{
                     "IsParallel" => false,
                     "Text" => "Default Text"
                   },
                   "PreparationStepIndex" => 0,
                   "Type" => "ManualText",
                   "OptionText" => "This is an option text",
                   "NextPrompt" => 3
                 },
                 %{
                   "Data" => %{
                     "IsParallel" => false,
                     "Text" => "Default Text"
                   },
                   "PreparationStepIndex" => 0,
                   "Type" => "ManualText",
                   "OptionText" => "This is another option text",
                   "NextAlternativePrompt" => 4,
                   "AlternativePrompts" => [
                     %{
                       "Data" => %{
                         "IsParallel" => false,
                         "Text" => "Default Text"
                       },
                       "PreparationStepIndex" => 0,
                       "Type" => "ManualText",
                       "NextAlternativePrompt" => 5
                     },
                     %{
                       "Data" => %{
                         "IsParallel" => false,
                         "Text" => "Default Text"
                       },
                       "PreparationStepIndex" => 0,
                       "Type" => "ManualText",
                       "NextPrompt" => 6
                     }
                   ]
                 }
               ]
             }
           ]
  end

  test ~s(checks correct parsing of prompts with alternative prompts with required devices) do
    assert RecipeAssets.recipe_prompts(
             "1.0",
             [
               %{"Type" => "ManualText", "NextPrompt" => 1},
               %{
                 "Type" => "ManualText",
                 "NextPrompt" => 2,
                 "AlternativeTitle" => "These are alternatives",
                 "Alternatives" => [
                   %{
                     "Type" => "ManualText",
                     "OptionText" => "This is an option text",
                     "NextPrompt" => 3,
                     "RequiredDevices" => [%{"Identifier" => "1234ABCD", "Type" => "test_device"}]
                   },
                   %{
                     "Type" => "ManualText",
                     "OptionText" => "This is another option text",
                     "NextAlternativePrompt" => 4,
                     "AlternativePrompts" => [
                       %{
                         "Type" => "ManualText",
                         "NextAlternativePrompt" => 5
                       },
                       %{
                         "Type" => "ManualText",
                         "NextPrompt" => 6
                       }
                     ]
                   }
                 ]
               }
             ]
           ) == [
             %{
               "Data" => %{
                 "IsParallel" => false,
                 "Text" => "Default Text"
               },
               "NextPrompt" => 1,
               "PreparationStepIndex" => 0,
               "Type" => "ManualText"
             },
             %{
               "Data" => %{
                 "IsParallel" => false,
                 "Text" => "Default Text"
               },
               "PreparationStepIndex" => 0,
               "Type" => "ManualText",
               "NextPrompt" => 2,
               "AlternativeTitle" => "These are alternatives",
               "Alternatives" => [
                 %{
                   "Data" => %{
                     "IsParallel" => false,
                     "Text" => "Default Text"
                   },
                   "PreparationStepIndex" => 0,
                   "Type" => "ManualText",
                   "OptionText" => "This is an option text",
                   "NextPrompt" => 3,
                   "RequiredDevices" => [
                     %{
                       "Identifier" => "1234ABCD",
                       "Type" => "test_device"
                     }
                   ]
                 },
                 %{
                   "Data" => %{
                     "IsParallel" => false,
                     "Text" => "Default Text"
                   },
                   "PreparationStepIndex" => 0,
                   "Type" => "ManualText",
                   "OptionText" => "This is another option text",
                   "NextAlternativePrompt" => 4,
                   "AlternativePrompts" => [
                     %{
                       "Data" => %{
                         "IsParallel" => false,
                         "Text" => "Default Text"
                       },
                       "PreparationStepIndex" => 0,
                       "Type" => "ManualText",
                       "NextAlternativePrompt" => 5
                     },
                     %{
                       "Data" => %{
                         "IsParallel" => false,
                         "Text" => "Default Text"
                       },
                       "PreparationStepIndex" => 0,
                       "Type" => "ManualText",
                       "NextPrompt" => 6
                     }
                   ]
                 }
               ]
             }
           ]
  end
end
