defmodule MessageBroker.Command do
  def parse(line) do
    # dbg("line is: #{inspect(line)}")

    line = String.trim(line)

    parsed =
      String.trim(line, "\r\n")
      |> String.split(" ", parts: 3)

    # dbg("parsed line is #{inspect(parsed)}")

    case parsed do
      ["help"] ->
        {:ok, {:help}}

      ["sub", topic] ->
        # dbg("was subscribe command to topic #{topic}")
        {:ok, {:subscribe, topic}}

      ["unsub", topic] ->
        # dbg("unsub from topic #{topic}")
        {:ok, {:unsubscribe, topic}}

      ["pub", topic, message] ->
        # dbg("was publish command to topic #{topic} and message #{message}")
        {:ok, {:publish, topic, message}}

      _ ->
        {:error, :unknown_command}
    end
  end

  def run(command, socket) do
    case command do
      {:help} ->
        send_message(socket, "Available commands are: sub (topic), pub (topic) (message), unsub (topic)")

      {:subscribe, topic} ->
        MessageBroker.SubscribersAgent.add_subscriber(topic, socket)
        send_message(socket, "subscribed successfully to topic #{topic}")

      {:unsubscribe, topic} ->
        MessageBroker.SubscribersAgent.unsubscribe_from_topic(topic, socket)
        send_message(socket, "unsubscribe successfully from topic #{topic}")

      {:publish, topic, message} ->
        topic_subscribers = MessageBroker.SubscribersAgent.get_topic_subscribers(topic)

        Enum.each(topic_subscribers, fn subscriber ->
          send_message(subscriber, message)
        end)

        send_message(socket, "message was send to #{inspect(length(topic_subscribers))}")
    end
  end

  def send_message(socket, message) do
    :gen_tcp.send(socket, message <> "\r\n")
  end
end
