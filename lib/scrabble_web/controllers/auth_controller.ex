defmodule ScrabbleWeb.AuthController do
  use ScrabbleWeb, :controller
  alias Scrabble.Accounts

  # Render registration form
  def new(conn, _params) do
    render(conn, "register.html")
  end

  # Handle registration form submission
  def create(conn, %{"userid" => userid, "passwd" => passwd}) do
    case Accounts.register_user(%{"userid" => userid, "passwd" => passwd}) do
      {:ok, _user} ->
        conn
        |> put_flash(:info, "User registered successfully!")
        |> redirect(to: "/login")
      {:error, changeset} ->
        render(conn, "register.html", changeset: changeset)
    end
  end

  # Render login form
  def login_form(conn, _params) do
    render(conn, "login.html")
  end

  # Handle login form submission
  def login(conn, %{"userid" => userid, "passwd" => passwd}) do
    case Accounts.authenticate_user(userid, passwd) do
      {:ok, user} ->
        conn
        |> put_session(:user_id, user.id)  # Store user ID in the session
        |> put_flash(:info, "Login successful!")
        |> redirect(to: "/")
      {:error, _reason} ->
        put_flash(conn, :error, "Invalid credentials")
        |> render("login.html")
    end
  end

  # Handle logout
  def logout(conn, _params) do
    conn
    |> configure_session(drop: true)  # Drop the session
    |> redirect(to: "/")
  end
end
