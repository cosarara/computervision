defmodule CvWeb.MethodControllerTest do
  use CvWeb.ConnCase

  alias Cv.Methods

  @create_attrs %{name: "some name", url: "some url", version: 42}
  @update_attrs %{name: "some updated name", url: "some updated url", version: 43}
  @invalid_attrs %{name: nil, url: nil, version: nil}

  def fixture(:method) do
    {:ok, method} = Methods.create_method(@create_attrs)
    method
  end

  describe "index" do
    test "lists all methods", %{conn: conn} do
      conn = get(conn, Routes.method_path(conn, :index))
      assert html_response(conn, 200) =~ "Listing Methods"
    end
  end

  describe "new method" do
    test "renders form", %{conn: conn} do
      conn = get(conn, Routes.method_path(conn, :new))
      assert html_response(conn, 200) =~ "New Method"
    end
  end

  describe "create method" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, Routes.method_path(conn, :create), method: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.method_path(conn, :show, id)

      conn = get(conn, Routes.method_path(conn, :show, id))
      assert html_response(conn, 200) =~ "Show Method"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.method_path(conn, :create), method: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Method"
    end
  end

  describe "edit method" do
    setup [:create_method]

    test "renders form for editing chosen method", %{conn: conn, method: method} do
      conn = get(conn, Routes.method_path(conn, :edit, method))
      assert html_response(conn, 200) =~ "Edit Method"
    end
  end

  describe "update method" do
    setup [:create_method]

    test "redirects when data is valid", %{conn: conn, method: method} do
      conn = put(conn, Routes.method_path(conn, :update, method), method: @update_attrs)
      assert redirected_to(conn) == Routes.method_path(conn, :show, method)

      conn = get(conn, Routes.method_path(conn, :show, method))
      assert html_response(conn, 200) =~ "some updated name"
    end

    test "renders errors when data is invalid", %{conn: conn, method: method} do
      conn = put(conn, Routes.method_path(conn, :update, method), method: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit Method"
    end
  end

  describe "delete method" do
    setup [:create_method]

    test "deletes chosen method", %{conn: conn, method: method} do
      conn = delete(conn, Routes.method_path(conn, :delete, method))
      assert redirected_to(conn) == Routes.method_path(conn, :index)
      assert_error_sent 404, fn ->
        get(conn, Routes.method_path(conn, :show, method))
      end
    end
  end

  defp create_method(_) do
    method = fixture(:method)
    %{method: method}
  end
end
