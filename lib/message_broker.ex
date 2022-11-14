defmodule MessageBroker do
  use Application
  require Logger

  @impl true
  def start(_type, _args) do
    Logger.info("Starting MessageBroker")
    children = [MessageBroker.SubscribersAgent]
    opts = [strategy: :one_for_one, name: MessageBroker.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
