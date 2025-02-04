defmodule ScrabbleWeb.Router do
  use ScrabbleWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {ScrabbleWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  scope "/", ScrabbleWeb do
    pipe_through :browser

    live "/", LandingPageLive
    live "/rules", RulesLive
    live "/register", RegistrationLive
    live "/login", LoginLive
    live "/dashboard", DashboardLive
    live "/game/:code", GameLive
  end
end
