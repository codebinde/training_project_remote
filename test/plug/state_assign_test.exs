defmodule Plug.StateAssignTest do
  use ExUnit.Case
  use Plug.Test

  test "assigns the state" do
    OnlineMock.State.put([:state_assign_test], :value)
    opts = Plug.StateAssign.init(key: :state_assign_test)
    conn = Plug.StateAssign.call(conn(:get, "/"), opts)
    assert conn.assigns[:state_assign_test] == :value
  end

  test "assigns a default in case of no state" do
    OnlineMock.State.pop([:state_assign_test])
    opts = Plug.StateAssign.init(key: :state_assign_test, default: :default_value)
    conn = Plug.StateAssign.call(conn(:get, "/"), opts)
    assert conn.assigns[:state_assign_test] == :default_value
  end
end
