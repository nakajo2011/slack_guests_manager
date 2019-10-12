defmodule Hello.SlackProvider do
  @moduledoc false

  use Slack

  def api_token do
    Application.get_env(:hello, HelloWeb.Endpoint)[:slack_api_token]
  end

  def user_list do
    channels = channel_list
    list = Slack.Web.Users.list(
             %{token: api_token}
           )
           |> Map.fetch!("members")
           |> Enum.map(fn u -> replace_channel_info(u, channels) end)
    list
  end

  def channel_list do
    list = Slack.Web.Channels.list(
             %{token: api_token}
           )
           |> Map.fetch!("channels")
           |> Enum.map(fn c -> {c["id"], c} end)
           |> Map.new
    list
  end

  def replace_channel_info(user, channels) do
    Map.put(user, :guest_channels, replaced_channels(user["profile"]["guest_channels"], channels))
  end

  def replaced_channels(gclist, channels) do
    list = case gclist do
      nil -> nil
      "[]" -> nil
      "" -> nil
      clist -> Jason.decode!(clist)
               |> Enum.map(fn c -> Map.get(channels, c) end)
    end
  end
end
