defmodule ElixirShop.Plugs.RequireAuth do
  import Plug.Conn

  def init(options) do
    options
  end

  def call(conn, _) do
    if conn.current_user do
      conn
    else
      conn |> put_status(401) |> halt
    end
  end
end
