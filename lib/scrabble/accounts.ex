defmodule Scrabble.Accounts do
  alias Scrabble.Repo
  alias Scrabble.User

  def register_user(attrs) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end

  def authenticate_user(userid, password) do
    user = Repo.get_by(User, userid: userid)

    cond do
      user && Bcrypt.verify_pass(password, user.passwd_hash) ->  # Changed from Comeonin.Bcrypt.checkpw
        {:ok, user}
      user ->
        {:error, :invalid_password}
      true ->
        {:error, :invalid_username}
    end
  end
end
