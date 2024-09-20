defmodule Plug.StatusResponder do
  @moduledoc """
  A plug that sends defined responses for configured paths.

  ## Methods

  * `set_status_response` - Set the HTTP response for a given path (for example `['html',
  'custom_recipe', 'index .html']`) to a arbitrary integer value.
  * `unset_status_response` - Respond with HTTP 200/OK and return a URI for a given path (for
  example `['html', 'custom_recipe', 'index.html']`).

  `set_status_response` accepts three arguments: `path_info` (list), `status` (integer) and an
  optional `body` (string).
  `unset_status_response` accepts the `path_info` (list) as argument.
  """

  import Plug.Conn

  @behaviour Plug

  @impl Plug
  def init(_opts), do: []

  @impl Plug
  def call(conn, _opts) do
    case OnlineMock.State.get([__MODULE__, conn.path_info]) do
      nil ->
        conn

      {status, body} ->
        conn
        |> send_resp(status, body)
        |> halt()
    end
  end

  def set_status_response(path_info, status, %XMLRPC.Base64{} = body) do
    {_, body} = XMLRPC.Base64.to_binary(body)
    OnlineMock.State.put([__MODULE__, path_info], {status, body})
  end

  def set_status_response(path_info, status, body) do
    OnlineMock.State.put([__MODULE__, path_info], {status, body})
  end

  def unset_status_response(path_info) do
    OnlineMock.State.put([__MODULE__, path_info], nil)
  end
end
