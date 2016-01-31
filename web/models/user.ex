defmodule ElixirShop.User do
  use ElixirShop.Web, :model
  use Ecto.Model.Callbacks

  before_insert :set_password_digest

  schema "users" do
    field :name, :string
    field :email, :string
    field :password, :string, virtual: true
    field :password_digest, :string
    timestamps
  end

  @required_fields ~w(name email password)
  @optional_fields ~w()

  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
    |> validate_format(:email, ~r/^.+@.+$/)
    |> validate_length(:username, min: 3)
    |> validate_length(:username, max: 50)
    |> validate_length(:password, min: 5)
    |> validate_length(:password, max: 255)
    |> unique_constraint(:email)
    |> unique_constraint(:name)
  end

  def check_password(user, entered_password) do
    Comeonin.Bcrypt.checkpw(entered_password, user.password_digest)
  end

  defp crypt_password(password) do
    Comeonin.Bcrypt.hashpwsalt(password)
  end

  defp set_password_digest(changeset) do
    password = Ecto.Changeset.get_field(changeset, :password)
    change(changeset, %{password_digest: crypt_password(password)})
  end
end
