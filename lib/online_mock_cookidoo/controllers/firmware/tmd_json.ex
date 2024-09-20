defmodule OnlineMockCookidoo.Firmware.TMDJSON do
  @moduledoc false

  def show(%{links: links, version: version}) do
    %{
      _links: for({rel, href} <- links, into: %{}, do: {rel, %{href: href}}),
      version: version
    }
  end
end
