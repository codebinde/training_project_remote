defmodule Plug.CacheControl do
  @moduledoc """
  A plug that handles cache control via etags.

  To generate the etag the module, function and arguments, prepended with the current connection,
  given via the option `:etag_generation` is invoked.

  ## Options

  * `:etag_generation` - A tuple consisting of a module, a function, and a list of default arguments
  (required).
  """

  require Logger

  import Plug.Conn

  alias Plug.Conn

  @behaviour Plug
  @retrieve_methods ~w(GET HEAD)
  @provide_methods ~w(PUT POST)

  @impl Plug
  def init(opts) do
    case Keyword.get(opts, :etag_generation) do
      nil ->
        raise ArgumentError, ":etag_generation required"

      etag_generation ->
        etag_generation
    end
  end

  @impl Plug
  def call(%Conn{method: method} = conn, etag_generation) when method in @retrieve_methods do
    case do_cache_control(conn, etag_generation, "if-none-match") do
      {:fresh, conn} ->
        conn
        |> send_resp(:not_modified, "")
        |> halt()

      {_, conn} ->
        conn
    end
  end

  def call(%Conn{method: method} = conn, etag_generation) when method in @provide_methods do
    case do_cache_control(conn, etag_generation, "if-match") do
      {:fresh, conn} ->
        conn

      {:new, conn} ->
        conn
        |> send_resp(:precondition_required, "")
        |> halt()

      {_, conn} ->
        conn
        |> send_resp(:precondition_failed, "")
        |> halt()
    end
  end

  def call(conn, _opts) do
    conn
  end

  defp do_cache_control(conn, {module, function, args}, header_match_tag) do
    etag = apply(module, function, [conn | args])
    conn = put_resp_header(conn, "etag", etag)

    req_header_content = get_req_header(conn, header_match_tag)

    cond do
      Enum.empty?(req_header_content) ->
        Logger.debug("no #{header_match_tag}, etag=#{inspect(etag)}")
        {:new, conn}

      Enum.member?(req_header_content, etag) ->
        Logger.debug("etag matched: etag=#{inspect(etag)}")
        {:fresh, conn}

      true ->
        Logger.debug(
          "etag did not match: #{header_match_tag}=#{inspect(req_header_content)} etag=#{inspect(etag)}"
        )

        {:stale, conn}
    end
  end
end
