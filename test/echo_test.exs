defmodule OTP.EchoTest do
  use ExUnit.Case, async: true

  alias OTP.Echo

  test "echo" do
    {:ok, pid} = Echo.start_link()

    ref = Echo.async_send(pid, :hello)
    assert_receive {^ref, :hello}

    ref = Echo.async_send(pid, :hello)
    assert_receive {^ref, :hello}

    send(pid, :another_message)
    assert Process.alive?(pid)
  end

  test "times out after 50 ms" do
    {:ok, pid} = Echo.start_link()

    Process.sleep(51)
    refute Process.alive?(pid)
  end

  test "sync echo" do
    {:ok, pid} = Echo.start_link()

    assert :hello == Echo.sync_send(pid, :hello)
  end

  test "sync send also times out" do
    {:ok, pid} = Echo.start_link()

    assert {:error, :timeout} == Echo.sync_send(pid, :no_reply)
  end

  test "sync msg racecondition" do
    {:ok, pid} = Echo.start_link()

    send(self(), :long_computation)
    assert {:error, :timeout} == Echo.sync_send(pid, :no_reply)
  end
end
