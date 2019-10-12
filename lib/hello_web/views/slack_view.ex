defmodule HelloWeb.SlackView do
  use HelloWeb, :view
  use Slack

  def get_keys(conn) do
    conn
    |> Map.fetch!("members")
    |> hd
    |> Map.keys()
  end

  def get_names(conn) do
    conn
    |> Map.fetch!("members")
    |> Enum.map(fn x -> Map.fetch!(x, "name") end)
  end

  def get_guests(member) do
    member
    |> Enum.filter(fn x -> x["is_restricted"] end)
  end

  def get_multiguests(member) do
    member
    |> Enum.filter(fn x -> is_multiguest(x) end)
  end

  def get_guest_permission_name(member) do
    case is_multiguest(member) do
      false -> "ゲスト"
      true -> "マルチゲスト"
      _ -> ""
    end
  end

  def is_multiguest(member) do
    member["is_restricted"] && !member["is_ultra_restricted"]
  end

  def expire_date_to_dateTime(member) do
    case {is_multiguest(member), member["profile"]["guest_expiration_ts"]} do
      {false, nil} ->
        "-"

      {true, nil} ->
        "無期限"

      {_, timestamp} ->
        DateTime.from_unix(timestamp)
        |> date_to_localize
        |> to_date_string
    end
  end

  def date_to_localize({:ok, datetime}) do
    DateTime.add(datetime, 9 * 60 * 60, :second)
  end

  def to_date_string(d) do
    "#{d.year}/#{d.month}/#{d.day} #{d.hour}:#{d.minute}:#{d.second}"
  end

  def channels(member) do
    cids =
      case member.guest_channels do
        nil -> []
        clist -> Enum.map(clist, fn c -> c["name"] end)
      end

    Enum.join(cids, ", ")
  end
end
