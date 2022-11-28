```elixir
# start server
iex --no-pry -S mix run
```

```elixir
# to connect to server
telnet localhost 8000
```

```elixir
# to subscribe
sub topic_name

# to unsub
unsub topic_name

# to publish to topic
pub topic_name message_for_topic
```
