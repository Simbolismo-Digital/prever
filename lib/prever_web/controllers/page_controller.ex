defmodule PreverWeb.PageController do
  use PreverWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
