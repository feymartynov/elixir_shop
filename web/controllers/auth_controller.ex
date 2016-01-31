require IEx

defmodule ElixirShop.AuthController do
  use ElixirShop.Web, :controller

  alias ElixirShop.User

  def new(conn, _params) do
    render(conn, "new.html", changeset: User.changeset(%User{}))
  end

  def create(conn, %{"user" => user_params}) do
    user = Repo.get_by(User, name: user_params["name"])

    if user && User.check_password(user, user_params["password"]) do
      conn
      |> put_session(:current_user_id, user.id)
      |> put_flash(:info, "Successfully logged in.")
      |> redirect(to: "/")
    else
      conn
      |> put_flash(:error, "Failed to log in.")
      |> redirect(to: auth_path(conn, :new))
    end
  end

  def destroy(conn, _params) do
    conn
    |> put_session(:current_user_id, nil)
    |> put_flash(:info, "Successfully logged out.")
    |> redirect(to: "/")
  end
end
