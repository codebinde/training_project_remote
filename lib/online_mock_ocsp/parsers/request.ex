defmodule OnlineMockOCSP.Parsers.Request do
  @moduledoc false

  @behaviour Plug.Parsers

  def init(opts) do
    Keyword.pop(opts, :body_reader, {Plug.Conn, :read_body, []})
  end

  def parse(conn, "application", "ocsp-request", _headers, {{mod, fun, args}, opts}) do
    apply(mod, fun, [conn, opts | args])
    |> decode()
  end

  def parse(conn, _type, _subtype, _headers, _opts) do
    {:next, conn}
  end

  defp decode({:ok, "", _conn}) do
    raise Plug.BadRequestError
  end

  defp decode({:ok, body, conn}) do
    result =
      try do
        PKI.decode!(body, :OCSPRequest)
      rescue
        _ -> :malformed_request
      end

    {:ok, %{"_ocsp_request" => result}, conn}
  end

  defp decode({:more, _, conn}) do
    {:error, :too_large, conn}
  end

  defp decode({:error, :timeout}) do
    raise Plug.TimeoutError
  end

  defp decode({:error, _}) do
    raise Plug.BadRequestError
  end
end
