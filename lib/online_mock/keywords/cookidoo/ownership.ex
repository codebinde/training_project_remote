defmodule OnlineMock.Keywords.Cookidoo.Ownership do
  @moduledoc false

  use RemoteLibrary

  alias OnlineMock.Data.OwnershipList

  @vorwerk "VorwerkRecipe"
  @created "CreatedRecipe"
  @allowed_types [@vorwerk, @created]

  @keyword "Remove Recipe From Device Owner Set"
  @keyword_args %{recipe_id: {nil, nil}}
  @keyword_doc """
  Removes a recipe from the device owner set.

  - ``recipe_id`` - id of the recipe to remove

  *Example*
  | _Remove Recipe From Device Owner Set_ | recipe_01 |
  """
  @spec remove_from_device_owner_set(String.t()) :: :ok
  def remove_from_device_owner_set(recipe_id) do
    OwnershipList.remove(recipe_id)

    :ok
  end

  @keyword "Append Recipe To Device Owner Set"
  @keyword_args %{recipe_id: {nil, nil}, type: {@vorwerk, nil}}
  @keyword_doc """
  Appends a recipe to the device owner set.

  - ``recipe_id`` - id of the recipe
  - ``type`` - must be one of ``#{@vorwerk}`` or ``#{@created}``

  *Examples*
  | _Append Recipe To Device Owner Set_ | recipe_01 | #{@created} |
  | _Append Recipe To Device Owner Set_ | recipe_02 |
  """
  @spec append_to_device_owner_set(String.t(), String.t()) :: :ok
  def append_to_device_owner_set(recipe_id, type) when type in @allowed_types do
    OwnershipList.append(recipe_id, type)

    :ok
  end

  @keyword "Append Recipes To Device Owner Set"
  @keyword_args %{recipe_ids: {nil, "list"}, type: {@vorwerk, nil}}
  @keyword_doc """
  Appends multiple recipes to the device owner set.

  - ``recipe_ids`` - list of recipe ids
  - ``type`` - must be one of ``#{@vorwerk}`` or ``#{@created}``. All recipes passed
      to this keyword will have the type set to this value.

  *Examples*
  | _Append Recipes To Device Owner Set_ | ["recipe_01", "recipe_02"] | #{@created} |
  | _Append Recipes To Device Owner Set_ | ["recipe_03", "recipe_04"] |
  """
  @spec append_multiple_to_device_owner_set([String.t()], String.t()) :: :ok
  def append_multiple_to_device_owner_set(recipe_ids, type)
      when type in @allowed_types do
    recipe_ids
    |> Enum.map(fn recipe_id -> [recipe_id, type, nil] end)
    |> OwnershipList.create()

    :ok
  end
end
