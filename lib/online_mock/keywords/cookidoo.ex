defmodule OnlineMock.Keywords.Cookidoo do
  @moduledoc false

  use RemoteLibrary

  @event_server_name OnlineMock
  @timeout_keyword_wait Application.compile_env!(:online_mock, :timeout_keyword_wait)

  @keyword_doc """
  Removes a SCS from the root home document.
  ...
  ...    The root home document provided by the online mock will have the specified entry missing.
  ...    To remove multiple entries, provide a list of SCS entries instead.
  ...
  ...    - ``scs`` - SCS entry/entries to remove from the root home document.
  """
  @keyword "Remove SCS From Root Home Document"
  def remove_scs(scs) do
    relation = "tmde2:" <> scs
    OnlineMock.RootHomeLinks.remove_link(relation)
  end

  @keyword_doc """
  Resets the SCS list to the default entries
  ...
  ...    Previously removed SCS entries from the root home document are restored with this keyword.
  """
  @keyword "Reset SCS List For Root Home Document"
  def reset_scs_list() do
    OnlineMock.RootHomeLinks.reset_links()
  end

  @keyword_doc """
  Inflate online mock HTML websites with hidden text to increase network traffic.
  ...
  ...    Inflates all online mock HTML websites with a hidden element containing
  ...    a configurable amount of text. This keyword will override the configuration
  ...    parameter from the environment.
  ...
  ...    - ``inflation_kb`` - Amount of data in KB to add to all HTML pages. Default is 100 KB.
  """
  @keyword "Inflate HTML Websites"
  @keyword_args %{inflation_kb: {100, "int"}}
  def inflate_html_websites(inflation_kb) do
    OnlineMockCookidoo.WebsiteInflation.set_inflation_kb(inflation_kb)
  end

  @keyword_doc """
  Removes the hidden text on all online mock HTML websites.
  ...
  ...    Removes the hidden text on all online mock HTML websites. This keyword
  ...    will override the configured value from the environment.
  """
  @keyword "Turn HTML Website Inflation Off"
  def turn_html_website_inflation_off() do
    OnlineMockCookidoo.WebsiteInflation.set_inflation_kb(0)
  end

  @keyword_doc """
  Resets the hidden text on all online mock HTML websites.
  ...
  ...    Resets the hidden text on all online mock HTML websites to the inital
  ...    state predefined by the environment
  """
  @keyword "Reset HTML Website Inflation"
  def reset_html_website_inflation() do
    OnlineMockCookidoo.WebsiteInflation.set_inflation_kb(nil)
  end

  @keyword "Restrict User-Agent"
  def restrict_user_agent(user_agent) do
    true = user_agent |> :binary.bin_to_list() |> List.ascii_printable?()
    false = String.contains?(user_agent, ["\n", "\r"])
    OnlineMock.State.put([Plug.UserAgent, OnlineMockCookidoo.Endpoint], user_agent)
    :ok
  end

  @keyword "Accept Every User-Agent"
  def allow_every_user_agent do
    OnlineMock.State.put([Plug.UserAgent, OnlineMockCookidoo.Endpoint], nil)
  end

  @keyword "Wait Until HTTP Request To Cookidoo Is Made For Path"
  def wait_cookidoo_request_path(path) do
    GenServer.call(
      @event_server_name,
      {:await, OnlineMockCookidoo, filter: fn x -> x.request_path == path end},
      @timeout_keyword_wait
    )
  end

  @keyword_doc """
  Defines a HTTP status response for a given path.
  ...
  ...    Make the mock respond with a fixed HTTP status code for a given URL to simulate desired behavior.
  ...
  ...    - ``path_info`` - URL in list style, for example: ``['html', 'custom_recipe', 'index.html']``
  ...    - ``status`` - HTTP status response, for example: ``500``
  ...    - ``body`` - Optional body, for example: ``internal server error``
  """
  @keyword "Set Status Response For Path"
  @keyword_args %{path_info: {nil, "list"}, status: {nil, "int"}, body: {"", nil}}
  defdelegate set_status_response(path_info, status, body), to: Plug.StatusResponder

  @keyword_doc """
  Returns a regular URL for a given path.
  ...
  ...    Make the mock respond normally for a given URL and respond with HTTP 200/OK.
  ...
  ...    - ``path_info`` - URL in list style, for example: ``['html', 'custom_recipe', 'index.html']``
  """
  @keyword "Unset Status Response For Path"
  @keyword_args %{path_info: {nil, "list"}}
  defdelegate unset_status_response(path_info), to: Plug.StatusResponder

  @keyword_doc """
  Get the number of access tokens sent to the wrong endpoints.
  """
  @keyword "Get Number Of Unexpected Access Tokens"
  def get_number_of_unexpected_access_tokens do
    OnlineMock.State.get([:access_token_found])
  end

  @keyword_doc """
  Get the content of tokens sent to the wrong endpoints.
  """
  @keyword "Get Unexpected Access Token Values"
  def get_unexpected_access_token_values do
    OnlineMock.State.get([:access_token_values])
  end

  @keyword_doc """
  Set the list of Access Tokens to be monitored at the endpoints.
  ...
  ... Sets the list of Access Tokens to be monitored, or resets to the default values
  ... when no list is provided.
  ...
  ... - ``token list`` - the list of tokens to be monitored, for example: ``["Bearer AccessToken", "Bearer OtherToken"]``
  ... (default: ["Bearer AccessToken"])
  """
  @keyword "Set Access Token Watchlist"
  @keyword_args %{token_list: {["Bearer AccessToken"], "list"}}
  def set_access_token_watchlist(token_list) do
    OnlineMock.State.put([:access_token_watchlist], token_list)
  end

  @keyword_doc """
  Sets the Resource Owner Password Credential Flow flag in the Root Home Document.

  - ``flag`` - Boolean, set to ${True} to use Resource Owner Password Credential Flow.
  """
  @keyword "Set Resource Owner Password Flow"
  @keyword_args %{flag: {"true", "bool"}}
  def set_resource_owner_password_flow(flag) do
    OnlineMock.State.put([:resource_owner_password_credential_flow], flag)
  end
end
