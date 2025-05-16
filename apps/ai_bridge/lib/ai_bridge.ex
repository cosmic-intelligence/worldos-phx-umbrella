defmodule AiBridge do
  @moduledoc """
  Documentation for `AiBridge`.
  """

  @doc """
  Hello world.

  ## Examples

      iex> AiBridge.hello()
      :world

  """

  @python_path Path.expand("../priv/python", __DIR__)
  def ping(text) when is_binary(text) do
    {:ok, pid} =
      :python.start([{:python_path, to_charlist(@python_path)}])

    raw = :python.call(pid, :echo, :ping, [text])
    :python.stop(pid)

    to_string(raw)
  end
end
