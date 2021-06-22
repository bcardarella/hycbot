defmodule HYCBot.Application do
  use Application

  def start(_type, _args) do
    Supervisor.start_link([HYCBot.Scheduler], strategy: :one_for_one)
  end
end
