defmodule AiBridgeTest do
  use ExUnit.Case, async: true

  test "ping returns PONG text" do
    assert AiBridge.ping("hi") == "PONG: hi"
  end
end
