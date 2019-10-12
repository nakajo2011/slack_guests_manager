defmodule HelloWeb.SlackController do
  use HelloWeb, :controller
  alias Hello.SlackProvider

  def index(conn, _params) do
    list = SlackProvider.user_list()
    render(conn, "index.html", list: list)
  end
end