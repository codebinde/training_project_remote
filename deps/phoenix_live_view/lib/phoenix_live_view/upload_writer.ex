defmodule Phoenix.LiveView.UploadWriter do
  @moduledoc ~S"""
  Provide a behavior for writing uploaded chunks to a final destination.

  By default, uploads are written to a temporary file on the server and
  consumed by the LiveView by reading the temporary file or copying it to
  durable location. Some usecases require custom handling of the uploaded
  chunks, such as streaming a user's upload to another server. In these cases,
  we don't want the chunks to be written to disk since we only need to forward
  them on.

  **Note**: Upload writers run inside the channel uploader process, so
  any blocking work will block the channel  errors will crash the channel process.

  Custom implementations of `Phoenix.LiveView.UploadWriter` can be passed to
  `allow_upload/3`. To initialize the writer with options, define a 3-arity function
  that returns a tuple of `{writer, writer_opts}`. For example imagine
  an upload writer that logs the chunk sizes and tracks the total bytes sent by the
  client:

      socket
      |> allow_upload(:avatar,
        accept: :any,
        writer: fn _name, _entry, _socket -> {EchoWriter, level: :debug} end
      )

  And such an `EchoWriter` could look like this:

      defmodule EchoWriter do
        @behaviour Phoenix.LiveView.UploadWriter

        @impl true
        def init(opts) do
          {:ok, %{total: 0, level: Keyword.fetch!(opts, :level)}}
        end

        @impl true
        def meta(state), do: %{level: state.level}

        @impl true
        def write_chunk(data, state) do
          size = byte_size(data)
          Logger.log(state.level, "received chunk of #{size} bytes")
          {:ok, %{state | state.total + size}}
        end

        @impl true
        def close(state) do
          Logger.log(state.level, "closing upload after #{state.total} bytes}")
          {:ok, state}
        end
      end

  When the LiveView consumes the uploaded entry, it will receive the `%{level: ...}`
  returned from the meta callback. This allows the writer to keep state as it handles
  chunks to be later relayed to the LiveView when consumed.
  """

  @callback init(opts :: term) :: {:ok, state :: term} | {:error, term}
  @callback meta(state :: term) :: map
  @callback write_chunk(data :: binary, state :: term) :: {:ok, state :: term} | {:error, term}
  @callback close(state :: term) :: {:ok, state :: term} | {:error, term}
end
