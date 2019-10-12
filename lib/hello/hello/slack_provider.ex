defmodule Hello.SlackProvider do
  @moduledoc false

  use Slack

  def api_token do
    Application.get_env(:hello, HelloWeb.Endpoint)[:slack_api_token]
  end

  def user_list do
    channels = channel_list

    Slack.Web.Users.list(%{token: api_token})
    |> Map.fetch!("members")
    |> Enum.map(fn u -> replace_channel_info(u, channels) end)
  end

  def channel_list do
    Slack.Web.Channels.list(%{token: api_token})
    |> Map.fetch!("channels")
    |> Enum.map(fn c -> {c["id"], c} end)
    |> Map.new()
  end

  def replace_channel_info(user, channels) do
    Map.put(user, :guest_channels, replaced_channels(user["profile"]["guest_channels"], channels))
  end

  def replaced_channels(nil, _), do: nil

  def replaced_channels("[]", _), do: nil

  def replaced_channels("", _), do: nil

  def replaced_channels(gclist, channels) do
    Jason.decode!(gclist)
    |> Enum.map(fn c -> Map.get(channels, c) end)
  end
end
