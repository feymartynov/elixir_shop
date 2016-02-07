defmodule ElixirShop.Plugs.CurrentUser do
  import Plug.Conn
  import Plug.Session

  alias ElixirShop.Repo
  alias ElixirShop.User

  def init(options) do
    options
  end

  def call(conn, _) do
    user = case get_session(conn, :current_user_id) do
      nil -> nil
      user_id -> Repo.get(User, user_id)
    end

    assign(conn, :current_user, user)
  end
end
