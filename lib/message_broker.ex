defmodule MessageBroker do
  use Application
  require Logger
  @moduledoc """
    Main application module, the entire application starts under this supervisor.
    This supervisor defines the children.
  """

  @impl true
  def start(_type, _args) do
    Logger.info("Starting MessageBroker")
    children = [
      MessageBroker.SubscribersAgent,
      {Task.Supervisor, name: MessageBroker.Server.TaskSupervisor},
      {Task, fn -> MessageBroker.Server.accept(8000) end}
    ]
    opts = [strategy: :one_for_one, name: MessageBroker.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
