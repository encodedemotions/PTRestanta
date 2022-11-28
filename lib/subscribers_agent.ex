defmodule MessageBroker.SubscribersAgent do
  use Agent
  require Logger

  def start_link(_opts) do
    Logger.info("Starting SubscribersAgent")
    Agent.start_link(fn -> %{} end, name: __MODULE__)
  end

  def add_subscriber(topic, subscriber) do
    Agent.update(
      __MODULE__,
      fn all_subscribers ->
        Map.update(
          all_subscribers,
          topic,
          [subscriber],
          fn topic_subscribers -> [subscriber | topic_subscribers] end
        )
      end
    )
  end

  def get_topic_subscribers(topic) do
    Agent.get(__MODULE__, fn all_subscribers -> Map.get(all_subscribers, topic, []) end)
  end

  def unsubscribe_from_topic(topic, subscriber) do
    Agent.update(__MODULE__, fn all_subscribers ->
      Map.update(
        all_subscribers,
        topic,
        [],
        fn topic_subscribers ->
          Enum.reject(topic_subscribers, fn x -> x == subscriber end)
        end
      )
    end)
  end

  def get_all() do
    Agent.get(__MODULE__, fn state -> state end)
  end
end
