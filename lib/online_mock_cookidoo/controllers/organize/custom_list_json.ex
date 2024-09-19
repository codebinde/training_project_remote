defmodule OnlineMockCookidoo.Organize.CustomListJSON do
  @moduledoc false

  use OnlineMockCookidoo, :verified_routes

  def index(_assigns) do
    %{
      "customlists" => OnlineMock.State.get([:customlists], []),
      "page" => %{
        "page" => 0,
        "totalPages" => 1,
        "totalElements" => length(OnlineMock.State.get([:customlists]))
      },
      "links" => %{"self" => ~p"/organize/custom-list?page=0"}
    }
  end

  def show(%{id: id}) do
    %{
      "id" => id,
      "title" => id,
      "asciiTitle" => id,
      "chapters" => [
        %{
          "recipes" => [
            %{
              "id" => id <> "r001",
              "title" => "Test Recipe 1 From " <> id,
              "asciiTitle" => "Test Recipe 1 From " <> id,
              "assets" => %{
                "images" => %{
                  "square" => "square"
                }
              }
            },
            %{
              "id" => id <> "r002",
              "title" => "Test Recipe 2 From " <> id,
              "asciiTitle" => "Test Recipe 2 From " <> id,
              "assets" => %{
                "images" => %{
                  "square" => "square"
                }
              }
            }
          ]
        }
      ],
      "recipeCount" => 2,
      "version" => 0,
      "assets" => %{
        "images" => %{
          "square" =>
            to_string(%URI{
              scheme: "https",
              host: "assets.tmecosys.com",
              path: "/images/{transformation}/" <> Macro.underscore(id)
            })
        }
      }
    }
  end
end
