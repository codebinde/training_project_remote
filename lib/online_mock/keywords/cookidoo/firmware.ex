defmodule OnlineMock.Keywords.Cookidoo.Firmware do
  @moduledoc false

  use RemoteLibrary

  @event_server_name OnlineMock
  @timeout_keyword_wait Application.compile_env!(:online_mock, :timeout_keyword_wait)
  @version_file "version-info.json"
  @version_field "version-number"
  @manifest_json "firmwareManifest.json"
  @manifest_file "vorwerk-image-manifest"

  @doc """
  Delays the response sent by `OnlineMockCookidoo.Firmware.UpdateController`
  """
  @keyword "Delay Reply Of Endpoint firmware/update"
  @spec cookidoo_firmware_update_delay(delay) :: :ok when delay: pos_integer() | nil
  def cookidoo_firmware_update_delay(delay) do
    OnlineMock.State.put([:firmware_update_delay], delay)
    :ok
  end

  @doc """
  Wait for requests of `OnlineMockCookidoo.Firmware.UpdateController` to be logged.

  It returns the SW version passed as a query parameter of the request.
  """
  @keyword "Wait Until OTA SW Update Is Checked"
  @keyword_args %{timeout: {@timeout_keyword_wait, "int"}}
  def wait_cookidoo_firmware_update(timeout) do
    %{query_params: %{"version" => version}} =
      GenServer.call(@event_server_name, {:await, :firmware_update}, timeout)

    version
  end

  @doc """
  Configure `OnlineMockCookidoo` to not provide OTA SW updates.
  """
  @keyword "Make OTA SW Update Unavailable"
  @spec configure_update_unavailable :: :ok
  def configure_update_unavailable do
    OnlineMock.State.put([:update_available], nil)
    :ok
  end

  @doc """
  Configure `OnlineMockCookidoo` to set the firmware-update-flag 'onboarding' to `true`.
  """
  @keyword "Configure Onboarding After OTA SW Update"
  @spec set_flag_onboarding :: :ok
  def set_flag_onboarding do
    OnlineMock.State.put([:firmware_update_onboarding], true)
    :ok
  end

  @doc """
  Configure `OnlineMockCookidoo` to set the firmware-update-flag 'onboarding' to `false`.
  """
  @keyword "Configure No Onboarding After OTA SW Update"
  @spec unset_flag_onboarding :: :ok
  def unset_flag_onboarding do
    OnlineMock.State.put([:firmware_update_onboarding], false)
    :ok
  end

  @doc """
  Configure `OnlineMockCookidoo` to set the firmware-update-flag 'enforce' to `true`.
  """
  @keyword "Configure Forced OTA SW Update"
  @spec set_flag_enforce :: :ok
  def set_flag_enforce do
    OnlineMock.State.put([:firmware_update_enforce], true)
    :ok
  end

  @doc """
  Configure `OnlineMockCookidoo` to set the firmware-update-flag 'enforce' to `false`.
  """
  @keyword "Configure Non-Forced OTA SW Update"
  @spec unset_flag_enforce :: :ok
  def unset_flag_enforce do
    OnlineMock.State.put([:firmware_update_enforce], false)
    :ok
  end

  @doc """
  Gets a list of downloaded firmware files.
  """
  @keyword "Get Downloaded Firmware Files"
  @keyword_doc @doc
  @spec lookup_download_firmware :: [String.t(), ...] | nil
  def lookup_download_firmware do
    GenServer.call(@event_server_name, {:values, :download_firmware})
  end

  @doc """
  Configure `OnlineMockCookidoo` to only provide a download link for firmware manifest and nothing
  else.
  """
  @keyword "Only Provide Manifest Download Link"
  @spec configure_fragments_only_manifest :: :ok
  def configure_fragments_only_manifest do
    OnlineMock.State.put([:firmware_update_fragments_filter], fn {name, _} ->
      String.starts_with?(name, "vorwerk-image-manifest-signed_")
    end)

    :ok
  end

  @doc """
  Configure `OnlineMockCookidoo` to provide links to downloads for all fragments.
  """
  @keyword "Provide All Download Links"
  @spec configure_fragments_all_links :: :ok
  def configure_fragments_all_links do
    OnlineMock.State.put([:firmware_update_fragments_filter], nil)
    :ok
  end

  @keyword "Configure Default Of Firmware Download Of Fragments To Be Chunked"
  @keyword_args %{number_of_chunks: {nil, "int"}, _: :*, timeout_ms: {1_000, "int"}}
  @keyword_doc """
  Configures the default behavior of all fragments of the firmware download to be sent in a sequence
  of chunks.

  If not configured seperately via file specific keywords fragments are split up into
  ``number_of_chunks`` chunks of the same size (up to 1 byte). Each chunk is sent one after another
  with a pause of ``timeout_ms`` ms in between.

  - ``number_of_chunks`` - determines the number of chunks the fragment is split up into
  - ``timeout_ms`` - timeout in milliseconds before the next chunk is sent
  """
  def configure_download_default_chunked(number_of_chunks, _ \\ [], timeout_ms) do
    OnlineMock.State.put(
      [Access.key(:firmware_download_behavior, %{}), :default],
      {:chunked, number_of_chunks, timeout_ms}
    )
  end

  @keyword "Configure Default Of Firmware Download Of Fragments Not To Be Chunked"
  @keyword_doc """
  Configures the default behavior of all fragments of the firmware download to be sent all at once.

  If not configured seperately via file specific keywords fragments are sent as a whole right away.
  """
  def configure_download_default_not_chunked do
    OnlineMock.State.pop([Access.key(:firmware_download_behavior, %{}), :default])
    :ok
  end

  @keyword "Configure Firmware Download Of Fragment To Be Chunked"
  @keyword_args %{
    file: {nil, nil},
    number_of_chunks: {nil, "int"},
    _: :*,
    timeout_ms: {1_000, "int"}
  }
  @keyword_doc """
  Configures a fragment of the firmware download to be sent in a sequence of chunks.

  The fragment ``file`` is split up into ``number_of_chunks`` chunks of the same size (up to 1
  byte). Each chunk is sent one after another with a pause of ``timeout_ms`` ms in between.

  - ``file`` - name of the fragment to be sent chunked
  - ``number_of_chunks`` - determines the number of chunks the fragment is split up into
  - ``timeout_ms`` - timeout in milliseconds before the next chunk is sent
  """
  def configure_download_fragment_chunked(file, number_of_chunks, _ \\ [], timeout_ms) do
    OnlineMock.State.put(
      [Access.key(:firmware_download_behavior, %{}), file],
      {:chunked, number_of_chunks, timeout_ms}
    )
  end

  @keyword "Configure Firmware Download Of All Fragments To Be Chunked"
  @keyword_args %{
    sw_version: {nil, nil},
    number_of_chunks: {nil, "int"},
    _: :*,
    timeout_ms: {1_000, "int"}
  }
  @keyword_doc """
  Configures all fragments of the firmware download of a SW version to be sent in a sequence of
  chunks.

  See `Configure Firmware Download Of Fragment To Be Chunked` how files are chunked.

  - ``sw_version`` - software version whose fragments will be sent chunked
  - ``number_of_chunks`` - determines the number of chunks the fragment is split up into
  - ``timeout_ms`` - timeout in milliseconds before the next chunk is sent
  """
  def configure_download_fragments_chunked(sw_version, number_of_chunks, _ \\ [], timeout_ms) do
    for {file, _} <- :ets.lookup_element(:sw_image_table, sw_version, 2) do
      configure_download_fragment_chunked(file, number_of_chunks, timeout_ms)
    end
  end

  @keyword "Configure Firmware Download Of Fragment Not To Be Chunked"
  @keyword_args %{file: {nil, nil}}
  @keyword_doc """
  Configures a fragment of the firmware download not to be sent chunked.

  The fragment ``file`` is send as a whole right away.

  - ``file`` - name of the fragment to be sent all at once
  """
  def configure_download_fragment_not_chunked(file) do
    OnlineMock.State.put([Access.key(:firmware_download_behavior, %{}), file], :not_chunked)
  end

  @keyword "Configure Firmware Download Of All Fragments Not To Be Chunked"
  @keyword_args %{sw_version: {nil, nil}}
  @keyword_doc """
  Configures all fragments of the firmware download of a SW version not to be sent chunked.

  See `Configure Firmware Download Of Fragment Not To Be Chunked`.

  - ``sw_version`` - software version whose fragments will be sent all at once
  """
  def configure_download_fragments_not_chunked(sw_version) do
    for {file, _} <- :ets.lookup_element(:sw_image_table, sw_version, 2) do
      configure_download_fragment_not_chunked(file)
    end
  end

  @keyword "Reset Firmware Download Of Fragment To The Default Behavior"
  @keyword_args %{file: {nil, nil}}
  @keyword_doc """
  Configures a fragment of the firmware download to be sent like the configured default.

  - ``file`` - name of the fragment to be sent all at once
  """
  def configure_download_fragment_default(file) do
    OnlineMock.State.pop([Access.key(:firmware_download_behavior, %{}), file])
    :ok
  end

  @keyword "Reset Firmware Download Of All Fragments To The Default Behavior"
  @keyword_args %{sw_version: {nil, nil}}
  @keyword_doc """
  Configures all fragments of the firmware download of a SW version to be sent like the configured
  default.

  - ``sw_version`` - software version whose fragments will be reset to the default behavior
  """
  def configure_download_fragments_default(sw_version) do
    for {file, _} <- :ets.lookup_element(:sw_image_table, sw_version, 2) do
      configure_download_fragment_default(file)
    end
  end

  @keyword "Pause Firmware Download Of Fragment At Chunk"
  @keyword_args %{file: {nil, nil}, chunk: {nil, "int"}}
  @keyword_doc """
  Locks the firmware download of a fragment at a certain chunk.

  In case a fragment is configured to be sent chunked the download will pause at the given chunk and
  waits for the chunk to be unlocked.

  - ``file`` - name of the fragment to be locked
  - ``chunk`` - number of the chunk to be locked
  """
  def pause_at_chunk(file, chunk) do
    OnlineMock.LockHandle.lock({:firmware_download_chunk, file, chunk})
  end

  @keyword "Pause Firmware Download Of All Fragments At Chunk"
  @keyword_args %{sw_version: {nil, nil}, chunk: {nil, "int"}}
  @keyword_doc """
  Locks the firmware download of all fragments of a SW version at a certain chunk.

  In case any fragment of the SW version is configured to be sent chunked the download will pause at
  the given chunk and waits for the chunk to be unlocked.

  - ``sw_version`` - software version whose fragments will be locked
  - ``chunk`` - number of the chunk to be locked
  """
  def pause_all_at_chunk(sw_version, chunk) do
    for {file, _} <- :ets.lookup_element(:sw_image_table, sw_version, 2) do
      pause_at_chunk(file, chunk)
    end
  end

  @keyword "Resume Firmware Download Of Fragment At Chunk"
  @keyword_args %{file: {nil, nil}, chunk: {nil, "int"}}
  @keyword_doc """
  Unlocks the firmware download of a fragment at a certain chunk.

  - ``file`` - name of the fragment to be unlocked
  - ``chunk`` - number of the chunk to be unlocked
  """
  def resume_at_chunk(file, chunk) do
    OnlineMock.LockHandle.unlock({:firmware_download_chunk, file, chunk})
  end

  @keyword "Resume Firmware Download Of All Fragments At Chunk"
  @keyword_args %{sw_version: {nil, nil}, chunk: {nil, "int"}}
  @keyword_doc """
  Unlocks the firmware download of all fragments of a SW version at a certain chunk.

  - ``sw_version`` - software version whose fragments will be unlocked
  - ``chunk`` - number of the chunk to be unlocked
  """
  def resume_all_at_chunk(sw_version, chunk) do
    for {file, _} <- :ets.lookup_element(:sw_image_table, sw_version, 2) do
      resume_at_chunk(file, chunk)
    end
  end

  @keyword "Get Name Of Manifest Fragment"
  @keyword_args %{sw_version: {nil, nil}}
  @keyword_doc """
  Returns the file name of the fragment of the manifest partition.

  - ``sw_version`` - software version whose manifest fragment is looked up
  """
  def get_manifest_fragment(sw_version) do
    :ets.lookup_element(:sw_image_table, sw_version, 2)
    |> Enum.find_value(fn
      {"vorwerk-image-manifest_" <> _ = file, _} -> file
      _ -> false
    end)
  end

  @doc """
  Configure `OnlineMockCookidoo` to provide OTA SW updates.

  `path_or_version` may be a path pointing to the archive containing the
   SW image.
  """
  @keyword "Make OTA SW Update Available"
  @spec configure_update_available(String.t()) :: :ok
  def configure_update_available(path_or_version) do
    if File.exists?(path_or_version) do
      do_configure_update_available({:path, path_or_version})
    else
      do_configure_update_available({:version, path_or_version})
    end
  end

  defp do_configure_update_available({:version, sw_version}) do
    if :ets.member(:sw_image_table, sw_version) do
      OnlineMock.State.put([:update_available], sw_version)
      sw_version
    else
      OnlineMock.State.put([:update_available], nil)
      nil
    end
  end

  defp do_configure_update_available({:path, sw_image}) do
    sw_version = extract_sw_version(sw_image)

    unless :ets.member(:sw_image_table, sw_version) do
      cache_sw_image(sw_version, sw_image)
    end

    OnlineMock.State.put([:update_available], sw_version)
    sw_version
  end

  @doc false
  def lookup_cached_sw_images do
    Stream.resource(
      fn -> :ets.first(:sw_image_table) end,
      fn
        :"$end_of_table" ->
          {:halt, nil}

        key ->
          next = :ets.next(:sw_image_table, key)
          {[key], next}
      end,
      fn _ -> nil end
    )
    |> Enum.into([])
  end

  @doc """
  Delays the response sent by `OnlineMockCookidoo.Firmware.HomeController`
  """
  @keyword "Delay Reply Of Endpoint firmware/.well-known/home"
  @spec cookidoo_firmware_home_delay(delay) :: :ok when delay: pos_integer() | nil
  def cookidoo_firmware_home_delay(delay) do
    OnlineMock.State.put([:firmware_home_delay], delay)
    :ok
  end

  @doc """
  Delays the response sent by `OnlineMockCookidoo.Firmware.TMDController`
  """
  @keyword "Delay Reply Of Endpoint firmware/tmd"
  @spec cookidoo_firmware_tmd_delay(delay) :: :ok when delay: pos_integer() | nil
  def cookidoo_firmware_tmd_delay(delay) do
    OnlineMock.State.put([:firmware_tmd_delay], delay)
    :ok
  end

  @doc """
  Locks TMF update if requested
  """
  @keyword "Lock TMF Update"
  def lock_tmf_update() do
    OnlineMock.LockHandle.lock(:firmware_tmd_lock)
    :ok
  end

  @doc """
  Unlocks TMF update if requested
  """
  @keyword "Unlock TMF Update"
  def unlock_tmf_update() do
    OnlineMock.LockHandle.unlock(:firmware_tmd_lock)
  end

  @doc """
  Locks TMF firmware download if requested
  """
  @keyword "Lock TMF Firmware Download"
  def lock_tmd_firmware_download() do
    OnlineMock.LockHandle.lock(:firmware_download)
    :ok
  end

  @doc """
  Unlocks TMF firmware download if requested
  """
  @keyword "Unlock TMF Firmware Download"
  def unlock_tmd_firmware_download() do
    OnlineMock.LockHandle.unlock(:firmware_download)
  end

  @doc """
  The TMF firmware download will be locked at the specified percentage.

  This keyword can also be used in subsequent steps,
  i.e:
  `Lock TMF Firmware Download At Percentage    20`
  `<test steps>`
  `Lock TMF Firmware Download At Percentage    50`
  -> the previous download will continue until 50 percent.
  If the updated lock percentage is smaller than the previous, an ongoing
  firmware will still be locked.
  Note:

  `percentage` Percentage at which the TMF firmware download will be locked. (Default: 50)
  """
  @keyword "Lock TMF Firmware Download At Percentage"
  @keyword_doc @doc
  @keyword_args %{percentage: {50, "int"}}
  @spec lock_firmware_download_at_percentage(pos_integer()) :: :ok
  def lock_firmware_download_at_percentage(percentage) do
    OnlineMock.State.put([:firmware_tmd_lock_percentage], percentage)
    # in case this call is a subsequent call,
    # let ongoing downloads continue to the new threshold
    OnlineMock.LockHandle.unlock(:firmware_percentage_lock)
    :ok
  end

  @doc """
  Removes the TMF firmware download percentage lock and unlocks all locked downloads.
  """
  @keyword "Remove And Unlock TMF Firmware Download Percentage Lock"
  @keyword_doc @doc
  @spec remove_and_unlock_firmware_download_percentage() :: :ok
  def remove_and_unlock_firmware_download_percentage() do
    OnlineMock.State.put([:firmware_tmd_lock_percentage], nil)
    OnlineMock.LockHandle.unlock(:firmware_percentage_lock)
  end

  @keyword "Make OTA TMF Firmware Update Available"
  def configure_tmf_available(version, path) do
    OnlineMock.State.put([:firmware_tmd], {version, path})
    :ok
  end

  @keyword "Make OTA TMF Firmware Update Unavailable"
  def configure_tmf_unavailable do
    OnlineMock.State.put([:firmware_tmd], nil)
    :ok
  end

  @keyword "Configure OTA TMF Firmware To Respond With BAD_REQUEST"
  def configure_tmf_response_bad_request do
    OnlineMock.State.put([:firmware_tmd], :bad_request)
    :ok
  end

  @keyword "Configure OTA TMF Firmware To Respond With INTERNAL_SERVER_ERROR"
  def configure_tmf_response_internal_server_error do
    OnlineMock.State.put([:firmware_tmd], :internal_server_error)
    :ok
  end

  defp extract_sw_version(sw_image) do
    {:ok, files} = :erl_tar.table(sw_image, [:compressed])
    version_file = find_file(@version_file, files)

    {:ok, [{_, version}]} =
      :erl_tar.extract(sw_image, [:memory, :compressed, {:files, [version_file]}])

    version
    |> Jason.decode!()
    |> Map.fetch!(@version_field)
  end

  defp cache_sw_image(sw_version, sw_image) do
    key = Application.fetch_env!(:online_mock, :enc_key)
    ivec = Application.fetch_env!(:online_mock, :enc_ivec)

    stored_fragments =
      for {file, content} <- extract_firmware_files(sw_image), file = Path.basename(file) do
        {file, store_encrypted(file, content, key, ivec)}
      end

    :ets.insert(:sw_image_table, {sw_version, stored_fragments})
  end

  defp find_file(name, files) do
    Enum.find(files, &String.contains?(to_string(&1), name))
  end

  defp extract_firmware_files(sw_image) do
    {:ok, files} = :erl_tar.table(sw_image, [:compressed])
    manifest_json = find_file(@manifest_json, files)

    [{_, manifest}] = extract_files(sw_image, [manifest_json])

    fragments =
      manifest
      |> Jason.decode!()
      |> Map.fetch!("fragments")
      |> Enum.map(fn x -> x |> Map.fetch!("source") |> find_file(files) end)

    manifest_file = find_file(@manifest_file, files)
    extract_files(sw_image, [manifest_file | fragments])
  end

  defp extract_files(sw_image, files) do
    {:ok, extracted} = :erl_tar.extract(sw_image, [:memory, :compressed, {:files, files}])
    extracted
  end

  defp store_encrypted(file, content, key, ivec) do
    # block_encrypt
    {enc, tag} = :crypto.crypto_one_time_aead(:aes_256_gcm, key, ivec, content, "", true)
    path = file <> "_" <> tag
    :ets.insert(:fragments_table, {path, {file, enc}})
    %{path: path, algorithm: "AES-256-GCM", key: key, ivec: ivec, tag: tag}
  end
end
