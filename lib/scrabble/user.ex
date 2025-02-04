# defmodule Scrabble.User do
#   use Ecto.Schema
#   import Ecto.Changeset

#   schema "users" do
#     field :userid, :string
#     field :passwd, :string, virtual: true  # Virtual field for password input
#     field :passwd_hash, :string
#     field :score, :integer, default: 0
#     timestamps()
#   end

#   def changeset(user, attrs) do
#     user
#     |> cast(attrs, [:userid, :passwd, :score])
#     |> validate_required([:userid, :passwd])
#     |> unique_constraint(:userid)
#     |> hash_password()
#   end


#   defp hash_password(changeset) do
#     if password = get_change(changeset, :passwd) do
#       put_change(changeset, :passwd_hash, Bcrypt.hash_pwd_salt(password))
#     else
#       changeset
#     end
#   end
# end
defmodule Scrabble.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :userid, :string
    field :passwd, :string, virtual: true  # Virtual field for password input
    field :passwd_hash, :string
    field :score, :integer, default: 0
    timestamps()
  end

  def changeset(user, attrs) do
    user
    |> cast(attrs, [:userid, :passwd, :score])
    |> validate_required([:userid, :passwd])
    |> unique_constraint(:userid)
    |> hash_password()
  end

  defp hash_password(changeset) do
    if password = get_change(changeset, :passwd) do
      put_change(changeset, :passwd_hash, Bcrypt.hash_pwd_salt(password))
    else
      changeset
    end
  end
end
