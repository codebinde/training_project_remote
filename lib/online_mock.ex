defmodule OnlineMock do
  @moduledoc false

  use GenServer
  use RemoteLibrary

  require Logger

  @name __MODULE__
  @timeout_keyword_wait Application.compile_env!(:online_mock, :timeout_keyword_wait)

  ## Robot Interface

  @keyword "Start Recording Online Events"
  @spec start_recording :: :ok
  def start_recording do
    GenServer.call(@name, :start_recording)
  end

  @keyword "Stop Recording Online Events"
  @spec stop_recording :: :ok
  def stop_recording do
    GenServer.call(@name, :stop_recording)
  end

  @doc """
  Clears up all Online events collected so far.
  """
  @keyword "Clear Online Events"
  @keyword_doc @doc
  @spec clear_events :: :ok
  def clear_events do
    GenServer.call(__MODULE__, :clear_events)
  end

  @keyword_doc """
  Logs ``message`` on level ``info``.
  """
  @keyword "Log Info"
  @keyword_args %{message: {nil, nil}}
  def log_info(message), do: Logger.info(message)

  @doc """
  Wait for the `:show` action of `OnlineMockCookidoo.RecipeAssets.RecipeController` to be logged.
  """
  @keyword "Wait For Recipe Request"
  @spec wait_cookidoo_recipe_request :: String.t()
  def wait_cookidoo_recipe_request do
    GenServer.call(@name, {:await, :recipe_request}, @timeout_keyword_wait)
  end

  @doc """
  Wait for the `:show` action with the given `recipe_id` of
  `OnlineMockCookidoo.RecipeAssets.RecipeController` to be logged.
  """
  @keyword "Wait For Recipe Request With Recipe ID"
  @spec wait_cookidoo_recipe_request_with_id(recipe_id) :: String.t() when recipe_id: String.t()
  def wait_cookidoo_recipe_request_with_id(recipe_id) do
    GenServer.call(
      @name,
      {:await, :recipe_request, filter: fn x -> x == recipe_id end},
      @timeout_keyword_wait
    )
  end

  @keyword "Configure Cookidoo Endpoint Response Delay"
  def configure_cookidoo_endpoint_response_delay(delay_in_ms) do
    OnlineMock.State.put([:delay_cookidoo_endpoint_response], delay_in_ms)
  end

  @keyword "Configure Cookidoo Subscription Active"
  def configure_cookidoo_subscription_active(subscription_active) do
    OnlineMock.State.put([:subscription, :active], subscription_active)
    :ok
  end

  @keyword "Configure Cookidoo Subscription Expiration Date"
  def configure_cookidoo_subscription_expiration(expiration_date) do
    OnlineMock.State.put([:subscription, :expires], expiration_date)
    :ok
  end

  @keyword "Get Last Device Deactivation Body"
  def get_device_deactivation_body() do
    OnlineMock.State.get([:device_deactivation_body])
  end

  @keyword "Configure Cookidoo Subscription Type"
  def configure_cookidoo_subscription_type(subscription_type) do
    OnlineMock.State.put([:subscription, :type], subscription_type)
    :ok
  end

  @keyword "Configure Cookidoo Subscription Status"
  def configure_cookidoo_subscription_status(subscription_status) do
    OnlineMock.State.put([:subscription, :status], subscription_status)
    :ok
  end

  @keyword "Configure Cookidoo Subscription Creation Date"
  def configure_cookidoo_subscription_created(subscription_created_date) do
    OnlineMock.State.put([:subscription, :_created], subscription_created_date)
    :ok
  end

  @keyword "Configure Cookidoo Subscription Modified Date"
  def configure_cookidoo_subscription_modified(modified_date) do
    OnlineMock.State.put([:subscription, :_modified], modified_date)
    :ok
  end

  @keyword "Configure Cookidoo Subscription Auto Renewal"
  def configure_cookidoo_subscription_auto_renew(subscription_auto_renew) do
    OnlineMock.State.put([:subscription, :autoRenewalProduct], subscription_auto_renew)
    :ok
  end

  @doc """
  Sets the subscription level. Valid values are one of `NONE`, `REDUCED` or `FULL`.
  """
  @keyword "Configure Cookidoo Subscription Level"
  def configure_cookidoo_subscription_level(subscription_level) do
    OnlineMock.State.put([:subscription, :subscriptionLevel], subscription_level)
    :ok
  end

  @keyword "Configure Consent Status"
  def configure_consent_status(consent_status) do
    OnlineMock.State.put([:consent, :status], consent_status)
    :ok
  end

  @keyword "Configure Show Consent Screen"
  def configure_show_consent(show_screen) do
    OnlineMock.State.put([:consent, :redirectURI], show_screen)
    :ok
  end

  @doc """
  Freezes the current time at `datetime`.
  """
  @spec freeze_time(datetime) :: :ok when datetime: Calender.datetime()
  def freeze_time(datetime) do
    OnlineMock.DateTime.configure(datetime)
  end

  @doc """
  Uses the current time and removes any offsets or freezes.
  """
  @keyword "Reset Time"
  @keyword_doc @doc
  @spec reset_time :: :ok
  def reset_time do
    OnlineMock.DateTime.configure(nil)
  end

  @keyword "Configure Infra Home Doc Request To Fail"
  @spec invalidate_home_doc :: :ok
  def invalidate_home_doc do
    OnlineMock.State.put([:home_doc_response], :internal_server_error)
    :ok
  end

  @keyword "Configure Infra Home Doc Request To Succeed"
  @spec validate_home_doc :: :ok
  def validate_home_doc do
    OnlineMock.State.put([:home_doc_response], :ok)
    :ok
  end

  @keyword "Configure Time Sync To Fail With Server Error"
  @spec invalidate_time :: :ok
  def invalidate_time do
    OnlineMock.State.put([:time_challenge_response], :internal_server_error)
    :ok
  end

  @keyword "Configure Time Sync To Fail With Challenge Mismatch"
  @spec invalidate_time_challenge :: :ok
  def invalidate_time_challenge do
    OnlineMock.State.put([:time_challenge_response], :send_invalid_challenge)
    :ok
  end

  @keyword "Configure Time Sync To Succeed"
  @spec validate_time :: :ok
  def validate_time do
    OnlineMock.State.put([:time_challenge_response], :OK)
    :ok
  end

  @doc """
  Sets an offset in days that is added to the current time whenever timestamps are created.
  """
  @keyword "Set Time Offset In Days"
  @keyword_doc @doc
  @spec set_time_offset_days(days) :: :ok when days: integer()
  def set_time_offset_days(days) do
    OnlineMock.DateTime.configure({:offset, {:day, days}})
  end

  @doc """
  Sets an offset in seconds that is added to the current time whenever timestamps are created.
  """
  @keyword "Set Time Offset In Seconds"
  @keyword_doc @doc
  @spec set_time_offset_seconds(seconds) :: :ok when seconds: integer()
  def set_time_offset_seconds(seconds) do
    OnlineMock.DateTime.configure({:offset, {:second, seconds}})
  end

  @keyword_doc """
  Set The Hour Of Timestamps For Online_mock

  This keyword is called to modify the hour of the actual timestamps, 
  which becomes the timestamps of the online_mock.
  The other parameters of timestamps(year, month, day, minutes and seconds)
  remain unchanged.

  - ``hour_of_day`` - Hour of the day in integer [0, 24]
  """
  @keyword "Set The Hour Of Timestamps For Online_mock"
  @keyword_args %{hour_of_day: {nil, "int"}}
  @spec set_hour_of_the_day(hour_of_day) :: :ok when hour_of_day: integer()
  def set_hour_of_the_day(hour_of_day) do
    date_utc_now = NaiveDateTime.utc_now()
    offset_hours = hour_of_day - date_utc_now.hour
    OnlineMock.DateTime.configure({:offset, {:hour, offset_hours}})
  end

  @doc """
  Freezes the time at the current time with an offset of `days`.
  """
  @keyword "Freeze Time At Offset In Days"
  @spec freeze_time_at_offset_days(days) :: :ok when days: integer()
  def freeze_time_at_offset_days(days) do
    Date.utc_today()
    |> Date.add(days)
    |> NaiveDateTime.new(Time.utc_now())
    |> elem(1)
    |> freeze_time()
  end

  @doc """
  Freezes the time at the current time with an offset of `seconds`.
  """
  @keyword "Freeze Time At Offset In Seconds"
  @spec freeze_time_at_offset_seconds(seconds) :: :ok when seconds: integer()
  def freeze_time_at_offset_seconds(seconds) do
    NaiveDateTime.utc_now()
    |> NaiveDateTime.add(seconds)
    |> freeze_time()
  end

  @doc """
  Rejects a client cert for a certain path.
  """
  @keyword "Reject Client Cert For Path"
  @keyword_doc @doc
  @spec reject_client_cert([String.t()]) :: :ok
  def reject_client_cert(path_info) do
    OnlineMock.State.put([:reject_client_cert, path_info], true)
    :ok
  end

  @doc """
  Accepts a client cert for a certain path.
  """
  @keyword "Accept Client Cert For Path"
  @keyword_doc @doc
  @spec accept_client_cert([String.t()]) :: :ok
  def accept_client_cert(path_info) do
    OnlineMock.State.put([:reject_client_cert, path_info], false)
    :ok
  end

  @doc """
  Invalidates a client cert for a certain controller.
  """
  @keyword "Invalidate Client Cert For Controller"
  @keyword_doc @doc
  @spec invalidate_client_cert(String.t()) :: :ok
  def invalidate_client_cert(controller) do
    controller = String.to_existing_atom("Elixir." <> controller)
    OnlineMock.State.put([:invalid_client_cert, controller], true)
    :ok
  end

  @doc """
  Validates a client cert for a certain controller.
  """
  @keyword "Validate Client Cert For Controller"
  @keyword_doc @doc
  @spec validate_client_cert(String.t()) :: :ok
  def validate_client_cert(controller) do
    controller = String.to_existing_atom("Elixir." <> controller)
    OnlineMock.State.put([:invalid_client_cert, controller], false)
    :ok
  end

  @doc """
  Set `thisUpdate` for OCSP responses to :default
  """
  @keyword "Set OCSP thisUpdate To Default"
  @spec set_this_update_default :: :ok
  def set_this_update_default do
    OnlineMock.State.put([:ocsp_this_update], :default)
    :ok
  end

  @doc """
  Set `thisUpdate` for OCSP responses to :now
  """
  @keyword "Set OCSP thisUpdate To Now"
  @spec set_this_update_now :: :ok
  def set_this_update_now do
    OnlineMock.State.put([:ocsp_this_update], :now)
    :ok
  end

  @doc """
  Set `nextUpdate` for OCSP responses to :default
  """
  @keyword "Set OCSP nextUpdate To Default"
  @spec set_next_update_default :: :ok
  def set_next_update_default do
    OnlineMock.State.put([:ocsp_next_update], :default)
    :ok
  end

  @doc """
  Set `nextUpdate` for OCSP responses to :now
  """
  @keyword "Set OCSP nextUpdate To Now"
  @spec set_next_update_now :: :ok
  def set_next_update_now do
    OnlineMock.State.put([:ocsp_next_update], :now)
    :ok
  end

  @doc """
  Removes the optional `nextUpdate` from OCSP responses
  """
  @keyword "Remove OCSP nextUpdate"
  @spec unset_next_update :: :ok
  def unset_next_update do
    OnlineMock.State.put([:ocsp_next_update], :not_set)
    :ok
  end

  @doc """
  Configures a certain endpoint to reuse TLS/SSL sessions.
  """
  @keyword "Reuse TLS/SSL Session In Endpoint"
  @keyword_doc @doc
  @spec reuse_session(endpoint) :: :ok when endpoint: atom() | String.t()
  def reuse_session(endpoint) do
    endpoint = Module.concat([endpoint])
    OnlineMock.State.put([endpoint, :reuse_session], true)
    :ok
  end

  @doc """
  Configures a certain endpoint not to reuse TLS/SSL sessions.
  """
  @keyword "Do Not Reuse TLS/SSL Session In Endpoint"
  @keyword_doc @doc
  @spec no_reuse_session(endpoint) :: :ok when endpoint: atom() | String.t()
  def no_reuse_session(endpoint) do
    endpoint = Module.concat([endpoint])
    OnlineMock.State.put([endpoint, :reuse_session], false)
    :ok
  end

  @doc """
  Makes encrypted recipe download unavailable
  """
  @keyword "Make Encrypted Recipe Download Unavailable"
  @keyword_doc @doc
  @spec make_encrypted_recipe_download_unavailable() :: :ok
  def make_encrypted_recipe_download_unavailable() do
    OnlineMock.State.put([:enc_recipe_download_available], false)
  end

  @doc """
  Makes encrypted recipe download available
  """
  @keyword "Make Encrypted Recipe Download Available"
  @keyword_doc @doc
  @spec make_encrypted_recipe_download_available() :: :ok
  def make_encrypted_recipe_download_available() do
    OnlineMock.State.put([:enc_recipe_download_available], true)
  end

  @doc """
  Sets a delay in milliseconds for sending files from /priv/static/mpd
  """
  @keyword "Set Delay For Video Streams"
  @keyword_doc @doc
  @spec set_video_stream_delay(delay_time :: integer()) :: :ok
  def set_video_stream_delay(delay_time) do
    OnlineMock.State.put([:video_stream, :delay], delay_time)
  end

  @doc """
  Sets a delay in milliseconds for sending segment
  """
  @keyword "Set Stream Segment Delay In Milliseconds"
  @keyword_doc @doc
  @spec make_video_stream_segment_delayed(segment :: integer(), delay_time :: integer()) :: :ok
  def make_video_stream_segment_delayed(segment, delay_time) do
    OnlineMock.State.put([:video_stream, :segments, segment], %{:delayed => delay_time})
  end

  @doc """
  Sets a delay in milliseconds for sending segment
  """
  @keyword "Set Stream Segments Delay In Milliseconds"
  @keyword_doc @doc
  @spec make_video_stream_segments_delayed(segments :: list(), delay_time :: integer()) :: :ok
  def make_video_stream_segments_delayed(segments, delay_time) do
    for segment <- segments do
      make_video_stream_segment_delayed(segment, delay_time)
    end

    :ok
  end

  @doc """
  Marks 404-not_found for request to segments
  """
  @keyword "Set Stream Segment Not Found"
  @keyword_doc @doc
  @spec make_video_stream_segment_not_found(segment :: integer()) :: :ok
  def make_video_stream_segment_not_found(segment) do
    OnlineMock.State.put([:video_stream, :segments, segment], :not_found)
  end

  @doc """
  Marks 500-internal-server-error for request to segments
  """
  @keyword "Set Stream Segment Internal Error"
  @keyword_doc @doc
  @spec make_video_stream_segment_halted(segment :: integer()) :: :ok
  def make_video_stream_segment_halted(segment) do
    OnlineMock.State.put([:video_stream, :segments, segment], :internal_server_error)
  end

  @doc """
  Locks the segments for download if requested
  """
  @keyword "Set Stream Segments Locked"
  @keyword_doc @doc
  @spec make_video_stream_segment_locked(segments :: list()) :: :ok
  def make_video_stream_segment_locked(segments) do
    for segment <- segments do
      OnlineMock.LockHandle.lock({:video_stream_segment, segment})
    end

    :ok
  end

  @doc """
  Unlocks the specified segment for download
  """
  @keyword "Unlock Stream Segment"
  @keyword_doc @doc
  @spec unlock_stream_segment(segment :: integer()) :: :ok
  def unlock_stream_segment(segment) do
    OnlineMock.LockHandle.unlock({:video_stream_segment, segment})
    :ok
  end

  @doc """
  Makes segments for download available again
  """
  @keyword "Make Stream Segment Available"
  @keyword_doc @doc
  @spec make_video_stream_segment_available(segment :: integer()) :: :ok
  def make_video_stream_segment_available(segment) do
    OnlineMock.State.update([:video_stream, :segments], &Map.drop(&1, [segment]))
  end

  @keyword "Load Macros From Directory"
  def load_macros_from_directory(dir) do
    dir = Path.expand(dir)

    for path <- dir |> File.ls!() |> Enum.map(&Path.join(dir, &1)), File.dir?(path) do
      OnlineMock.Data.Encrypted.Macro.create(path)
    end

    :ok
  end

  @keyword "Load Recipes From Directory"
  def load_recipes_from_directory(dir) do
    dir = Path.expand(dir)

    for file <- dir |> File.ls!(), Path.extname(file) == ".yaml" do
      Path.join(dir, file)
    end
    |> OnlineMock.Keywords.Cookidoo.RecipeAssets.load_recipes()

    :ok
  end

  # Interface

  @doc """
  Starts the `#{__MODULE__}` linked to the current process registered under the name `#{@name}`.
  """
  @spec start_link([]) :: GenServer.on_start()
  def start_link([]) do
    GenServer.start_link(__MODULE__, [], name: @name)
  end

  @doc """
  Logs an event.
  """
  @spec log_event(EventLog.event(), EventLog.value()) :: :ok
  def log_event(event, value) do
    GenServer.cast(@name, {:log_event, event, value})
  end

  # Callbacks

  @impl GenServer
  def init([]) do
    {:ok, %EventLog{}}
  end

  @impl GenServer
  def handle_call(:start_recording, _from, events) do
    {:reply, :ok, EventLog.start(events)}
  end

  def handle_call(:stop_recording, _from, events) do
    {:reply, :ok, EventLog.stop(events)}
  end

  def handle_call(:clear_events, _from, events) do
    {:reply, :ok, EventLog.clear(events)}
  end

  def handle_call({:await, event}, from, events) do
    EventLog.return_await(events, [], from, event)
  end

  def handle_call({:await, event, opts}, from, events) do
    EventLog.return_await(events, [], from, event, opts)
  end

  def handle_call({:values, event}, _from, events) do
    {:reply, EventLog.values(events, event), events}
  end

  def handle_call({:current_value, event}, _from, events) do
    {:reply, EventLog.current_value(events, event), events}
  end

  @impl GenServer
  def handle_cast({:log_event, event, value}, events) do
    {:noreply, EventLog.log(events, event, value)}
  end

  @impl GenServer
  def handle_info({:DOWN, ref, :process, _pid, _reason}, events) do
    {:noreply, EventLog.down(events, ref)}
  end
end
