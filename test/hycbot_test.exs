defmodule HycbotTest do
  use ExUnit.Case
  doctest Hycbot

  test "greets the world" do
    assert Hycbot.hello() == :world
  end
end
