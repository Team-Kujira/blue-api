defmodule BlueApi.Node do
  use Kujira.Node,
    otp_app: :blue_api,
    pubsub: BlueApi.PubSub,
    subscriptions: Kujira.Invalidator.subscriptions()
end
