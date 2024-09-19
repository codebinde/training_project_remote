defmodule Plug.CheckCookieEnforcementTest do
  use ExUnit.Case
  use Plug.Test

  alias Plug.CheckCookieEnforcement

  @required_cookies %{"cookie_req_1" => "req_value_1", "cookie_req_2" => "req_value_2"}
  @prohibited_cookies %{
    "cookie_prohib_1" => "prohib_value_1",
    "cookie_prohib_2" => "prohib_value_2"
  }
  @rules [required_cookies: @required_cookies, prohibited_cookies: @prohibited_cookies]

  setup do
    Application.put_env(:online_mock, :dummy_endpoint, @rules)
    Application.put_env(:online_mock, :dummy_other_endpoint, dummy_key: "dummy_value")

    :ok
  end

  test "allows request with valid cookie" do
    init_state =
      CheckCookieEnforcement.init(endpoint: :dummy_endpoint)

    conn =
      conn(:get, "/")
      |> put_req_header("cookie", "cookie_req_1=req_value_1; cookie_req_2=req_value_2")
      |> CheckCookieEnforcement.call(init_state)

    assert conn.status != Plug.Conn.Status.code(:forbidden)
    assert conn.status != Plug.Conn.Status.code(:bad_request)
    assert conn.halted == false
  end

  test "halts request with missing cookies" do
    init_state =
      CheckCookieEnforcement.init(endpoint: :dummy_endpoint)

    conn =
      conn(:get, "/")
      |> CheckCookieEnforcement.call(init_state)

    assert conn.status == Plug.Conn.Status.code(:forbidden)
    assert conn.resp_body == ""
    assert conn.halted == true
  end

  test "halts request with invalid cookie value" do
    init_state = CheckCookieEnforcement.init(endpoint: :dummy_endpoint)

    conn =
      conn(:get, "/")
      |> put_req_header("cookie", "cookie_req_1=wrong_value; cookie_req_2=req_value_2")
      |> CheckCookieEnforcement.call(init_state)

    assert conn.status == Plug.Conn.Status.code(:forbidden)
    assert conn.resp_body == ""
    assert conn.halted == true
  end

  test "halts request with prohibited cookies" do
    init_state = CheckCookieEnforcement.init(endpoint: :dummy_endpoint)

    conn =
      conn(:get, "/")
      |> put_req_header(
        "cookie",
        "cookie_req_1=req_value_1; cookie_req_2=req_value_2; cookie_prohib_1=prohib_value_1"
      )
      |> CheckCookieEnforcement.call(init_state)

    assert conn.status == Plug.Conn.Status.code(:bad_request)
    assert conn.resp_body == ""
    assert conn.halted == true
  end

  test "non configured rules have no effect" do
    init_state = CheckCookieEnforcement.init(endpoint: :dummy_other_endpoint)

    conn =
      conn(:get, "/")
      |> put_req_header(
        "cookie",
        "cookie_prohib_1=prohib_value_1; cookie_prohib_2=prohib_value_2"
      )
      |> CheckCookieEnforcement.call(init_state)

    assert conn.status != Plug.Conn.Status.code(:forbidden)
    assert conn.status != Plug.Conn.Status.code(:bad_request)
    assert conn.halted == false
  end
end
