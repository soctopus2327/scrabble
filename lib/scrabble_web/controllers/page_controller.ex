defmodule ScrabbleWeb.PageController do
  use ScrabbleWeb, :controller

  def home(conn, _params) do
    # The home page is often custom made,
    # so skip the default app layout.
    render(conn, :home, layout: false)
  end

  def landing(conn, _params) do
    render(conn, :landing)
  end

  def rules(conn, _params) do
    render(conn, :rules)
  end
end
