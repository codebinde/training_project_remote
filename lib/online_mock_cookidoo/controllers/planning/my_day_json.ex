defmodule OnlineMockCookidoo.Planning.MyDayJSON do
  @moduledoc false

  import OnlineMockCookidoo.Planning.Common

  def show(%{id: id}) do
    my_day_dto(id)
  end

  def update(%{id: id}) do
    %{
      "message" => "update response for my day #{id}",
      "content" => my_day_dto(id)
    }
  end

  def delete(%{id: id}) do
    %{
      "message" => "delete response for my day #{id}",
      "content" => my_day_dto(id)
    }
  end
end
