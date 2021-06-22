defmodule Mix.Tasks.Hycbot.Run do
  use Mix.Task
  @shortdoc "HYCBot Runner"

  def run(_args) do
    Mix.Tasks.Run.run(["--no-halt"])
  end
end
