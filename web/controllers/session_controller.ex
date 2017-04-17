defmodule Rumbl.SessionController do
  use Rumbl.Web, :controller
  alias Rumbl.Repo

  @moduledoc """
    Login / Logout management module
  """

  @doc """
    login page
  """
  def new(conn, _) do
    render conn, "new.html"
  end

  @doc """
    Validate login
  """
  def create(conn, %{"session" => %{"username" => user, "password" => pass}}) do
    case Rumbl.Auth.login_by_username_and_pass(conn, user, pass, repo: Repo) do
      {:ok, conn} ->
        conn
        |> put_flash(:info, "Welcome back #{user}")
        |> redirect(to: page_path(conn, :index))
      {:error, _reason, conn} ->
        conn
        |> put_flash(:error, "Invalid credentials")
        |> render("new.html")
    end
  end

  @doc """
    Logout
  """
  def delete(conn, _) do
    conn
    |> Rumbl.Auth.logout()
    |> redirect(to: page_path(conn, :index))
  end
end