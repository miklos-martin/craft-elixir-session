defmodule OTP.Echo do
  @receive_timeout 50
  @send_timeout 50

  def start_link do
    pid = spawn_link(&loop/0)
    {:ok, pid}
  end

  def async_send(pid, msg) do
    ref = make_ref()
    send(pid, {ref, msg, self()})
    ref
  end

  def sync_send(pid, msg) do
    ref = async_send(pid, msg)
    receive do
      {^ref, msg} -> msg
    after
      @send_timeout -> {:error, :timeout}
    end
  end

  defp loop do
    receive do
      {_, :no_reply, _} -> loop()

      {ref, msg, caller} ->
        Kernel.send(caller, {ref, msg})
        loop()

      _ -> loop()

    after
      @receive_timeout -> exit(:normal)
    end
  end
end
