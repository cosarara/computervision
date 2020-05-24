defmodule CvWeb.MethodController do
  use CvWeb, :controller

  alias Cv.Methods
  alias Cv.Methods.Method

  def index(conn, _params) do
    methods = Methods.list_methods()
    render(conn, "index.html", methods: methods)
  end

  def new(conn, _params) do
    changeset = Methods.change_method(%Method{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"method" => method_params}) do
    case Methods.create_method(method_params) do
      {:ok, method} ->
        conn
        |> put_flash(:info, "Method created successfully.")
        |> redirect(to: Routes.method_path(conn, :show, method))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    method = Methods.get_method!(id)
    render(conn, "show.html", method: method)
  end

  def edit(conn, %{"id" => id}) do
    method = Methods.get_method!(id)
    changeset = Methods.change_method(method)
    render(conn, "edit.html", method: method, changeset: changeset)
  end

  def update(conn, %{"id" => id, "method" => method_params}) do
    method = Methods.get_method!(id)

    case Methods.update_method(method, method_params) do
      {:ok, method} ->
        conn
        |> put_flash(:info, "Method updated successfully.")
        |> redirect(to: Routes.method_path(conn, :show, method))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", method: method, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    method = Methods.get_method!(id)
    {:ok, _method} = Methods.delete_method(method)

    conn
    |> put_flash(:info, "Method deleted successfully.")
    |> redirect(to: Routes.method_path(conn, :index))
  end
end
