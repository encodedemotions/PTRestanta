defmodule MessageBroker.Server do
  @moduledoc """
    TCP server with task supervisor that accepts incoming connections and takes care of thier requests.
    Most of this is unchanged from the TCP server documentation.
  """
  require Logger

  @doc """
    Accepts incoming connections on specified port.
  """
  def accept(port) do
    {:ok, socket} =
      :gen_tcp.listen(port, [:binary, packet: :line, active: false, reuseaddr: true])

    Logger.info("Accepting connections on port #{port}")
    loop_acceptor(socket)
  end

  @doc """
    For each connection start a new task under supervisor.
  """
  defp loop_acceptor(socket) do
    {:ok, client} = :gen_tcp.accept(socket)
    Logger.info("new client connected: #{inspect(client)}")
    :gen_tcp.send(client, "hello \n\r")

    {:ok, pid} =
      Task.Supervisor.start_child(MessageBroker.Server.TaskSupervisor, fn -> serve(client) end)

    :ok = :gen_tcp.controlling_process(client, pid)
    loop_acceptor(socket)
  end

  @doc """
    The started task executes the serve function in an infinite loop.
    Handles the clients' input (commands) and executes the actions based on those commands.
  """
  defp serve(socket) do
    with {:ok, data} <- read_line(socket),
         {:ok, command} <-
           MessageBroker.Command.parse(data) do
      # dbg("will run command #{inspect(command)}")
      MessageBroker.Command.run(command, socket)
    else
      {:error, :unknown_command} ->
        write_line("error, unknown command\r\n", socket)
    end

    serve(socket)
  end

  @doc """
    Reads from the TCP socket.
  """
  defp read_line(socket) do
    :gen_tcp.recv(socket, 0)
  end

  @doc """
    Writes to the TCP socket.
  """
  defp write_line(line, socket) do
    :gen_tcp.send(socket, line)
  end
end
