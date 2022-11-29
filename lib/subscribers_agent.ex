defmodule MessageBroker.SubscribersAgent do
  @moduledoc """
    The functionality of the shared state.
  """
  use Agent
  require Logger

  @doc """
    Starts and notifies that the SubscribersAgent module was started.
  """
  def start_link(_opts) do
    Logger.info("Starting SubscribersAgent")
    Agent.start_link(fn -> %{} end, name: __MODULE__)
  end

  def add_subscriber(topic, subscriber) do
    Logger.info("Topic = #{topic}")
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

  @doc """
    Displays the entire agent state (existing topics and the client that is connected to them).
  """
  def get_all() do
    Agent.get(__MODULE__, fn state -> state end)
  end
end
