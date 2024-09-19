defmodule OnlineMock.Keywords.Cookidoo.RecipeAssets do
  @moduledoc false

  use RemoteLibrary

  require Logger

  @modes_archive "modes.tar.gz"

  @keyword "Load Recipes"
  def load_recipes(recipes) do
    for path <- recipes do
      id = path |> Path.basename() |> Path.rootname()
      description = YamlElixir.read_from_file!(path)
      recipe = OnlineMock.RecipeAssets.recipe(id, description)
      OnlineMock.Data.Encrypted.Recipe.create(recipe)

      if variant_clusters = get_in(recipe, ["MetaData", "VariantClusters"]) do
        [%{"Uid" => uid}] = variant_clusters

        %{"first" => quantity, "second" => notation} =
          get_in(recipe, ["RecipeData", "RecipeInfo", "ServingQuantity"])

        variant = %{"recipe_id" => id, "quantity" => quantity, "notation" => notation}

        variants_database =
          case :ets.lookup(:recipe_variants, uid) do
            [] ->
              [variant]

            [{_, variants}] ->
              variants =
                Enum.reduce(
                  variants,
                  [],
                  fn x, acc ->
                    case Map.get(x, "recipe_id") do
                      ^id ->
                        acc

                      _ ->
                        [x | acc]
                    end
                  end
                )

              [variant | variants]
          end

        :ets.insert(:recipe_variants, {uid, variants_database})
      end
    end

    :ok
  end

  @customer "customer"
  @vorwerk "vorwerk"
  @allowed_sources [@vorwerk, @customer]
  @keyword "Load Recipes From JSON"
  @keyword_args %{recipe_paths: {nil, "list"}, source: {nil, nil}}
  @keyword_doc """
  Loads recipe JSON files directly into the online mock.

  Please note that the JSON file will be served as provided, so ensure the correctness
  of the recipe data beforehand. The recipe id will be set to the ``Id`` tag in the
  corresponding JSON file.

  - ``recipe_paths`` - list of full paths to the JSON files
  - ``source`` - must be either ``#{@vorwerk}`` or ``#{@customer}`` to determine the
  data providing endpoint for the recipes.

  *Example*
  | _Load Recipes From JSON_ | ["/path/to/recipe_01.json", "/path/to/recipe_02.json"] | #{@vorwerk} |
  """
  @spec load_recipe_json([String.t()], String.t()) :: :ok
  def load_recipe_json(recipe_paths, source) when source in @allowed_sources do
    for path <- recipe_paths do
      path
      |> File.read!()
      |> do_load_recipe_json(source)
    end

    :ok
  end

  defp do_load_recipe_json(recipe, @vorwerk) do
    OnlineMock.Data.Encrypted.Recipe.create(recipe, :json)
  end

  defp do_load_recipe_json(recipe, @customer) do
    OnlineMock.Data.CustomerRecipe.create(recipe)
  end

  @keyword "Load Customer Recipes"
  @keyword_args %{recipes: {nil, "list"}}
  @keyword_doc """
  Loads web app customer recipes into the online mock.

  - ``recipe_id`` - list of filepaths to the customer recipe yaml files
  """
  @spec load_customer_recipes([String.t()]) :: :ok
  def load_customer_recipes(recipes) do
    for path <- recipes do
      recipe = YamlElixir.read_from_file!(path)
      recipe_name = recipe["name"]
      recipe_steps = recipe["recipeSteps"]

      case OnlineMock.State.get([:customer_recipes]) do
        stored_customer_recipes when is_map(stored_customer_recipes) ->
          OnlineMock.State.put(
            [:customer_recipes],
            Map.put(stored_customer_recipes, recipe_name, recipe_steps)
          )

        _ ->
          OnlineMock.State.put(
            [:customer_recipes],
            %{recipe_name => recipe_steps}
          )
      end
    end
  end

  @doc """
  Configures `OnlineMockCookidoo` to provide modes and tools collection.

  `modes_and_tools` needs to be a list of list of exactly three elements `type`, `macro_id`, and
  `id`.  These modes and tools are created in case they do not exist yet.
  """
  @keyword "Make Modes and Tools Download Available"
  @spec make_modes_and_tools_download_available(String.t(), [mode_or_tool]) :: map()
        when mode_or_tool: [String.t()]
  def make_modes_and_tools_download_available(schema_version, modes_and_tools) do
    OnlineMock.Data.ModesAndTools.create(modes_and_tools, schema_version)
    :ok
  end

  @doc """
  Removes the modes and tools collection.
  """
  @keyword "Remove Modes And Tools Collection"
  @keyword_doc @doc
  @spec remove_modes_and_tools_collection() :: :ok
  def remove_modes_and_tools_collection do
    :ets.delete(:files_table, @modes_archive)
    :ok
  end

  @keyword "Lock Recipe Download"
  @keyword_args %{recipe_id: {nil, nil}, source: {@vorwerk, nil}}
  @keyword_doc """
  Locks a specific recipe for download if requested.

  - ``recipe_id`` - id of the recipe to lock
  - ``source`` - must be either ``#{@vorwerk}`` or ``#{@customer}`` to determine the
  data providing endpoint for the recipe

  *Examples*
  | _Lock Recipe Download_ | recipe_01 |
  | _Lock Recipe Download_ | delicious_cake | #{@customer} |
  """
  @spec lock_recipe_download(String.t(), String.t()) :: :ok
  def lock_recipe_download(recipe_id, source) when source in @allowed_sources do
    do_lock_recipe_download(recipe_id, source)
    :ok
  end

  defp do_lock_recipe_download(recipe_id, @vorwerk) do
    OnlineMock.LockHandle.lock({:recipe, recipe_id})
  end

  defp do_lock_recipe_download(recipe_id, @customer) do
    OnlineMock.LockHandle.lock({:customer_recipe, recipe_id})
  end

  @keyword "Unlock Recipe Download"
  @keyword_args %{recipe_id: {nil, nil}, source: {@vorwerk, nil}}
  @keyword_doc """
  Unlocks a previously locked recipe for download if requested.

  - ``recipe_id`` - id of the recipe to unlock
  - ``source`` - must be either ``#{@vorwerk}`` or ``#{@customer}`` to determine the
  data providing endpoint for the recipe

  *Examples*
  | _Unlock Recipe Download_ | recipe_01 |
  | _Unlock Recipe Download_ | delicious_cake | #{@customer} |
  """
  @spec unlock_recipe_download(String.t(), String.t()) :: :ok
  def unlock_recipe_download(recipe_id, source) when source in @allowed_sources do
    do_unlock_recipe_download(recipe_id, source)
  end

  defp do_unlock_recipe_download(recipe_id, @vorwerk) do
    OnlineMock.LockHandle.unlock({:recipe, recipe_id})
  end

  defp do_unlock_recipe_download(recipe_id, @customer) do
    OnlineMock.LockHandle.unlock({:customer_recipe, recipe_id})
  end
end
