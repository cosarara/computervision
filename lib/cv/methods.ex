defmodule Cv.Methods do
  @moduledoc """
  The Methods context.
  """

  import Ecto.Query, warn: false
  alias Cv.Repo

  alias Cv.Methods.Method

  @doc """
  Returns the list of methods.

  ## Examples

      iex> list_methods()
      [%Method{}, ...]

  """
  def list_methods do
    Repo.all(Method)
  end

  @doc """
  Gets a single method.

  Raises `Ecto.NoResultsError` if the Method does not exist.

  ## Examples

      iex> get_method!(123)
      %Method{}

      iex> get_method!(456)
      ** (Ecto.NoResultsError)

  """
  def get_method!(id), do: Repo.get!(Method, id)

  def by_name!(name), do: Repo.get_by!(Method, name: name)

  @doc """
  Creates a method.

  ## Examples

      iex> create_method(%{field: value})
      {:ok, %Method{}}

      iex> create_method(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_method(attrs \\ %{}) do
    %Method{}
    |> Method.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a method.

  ## Examples

      iex> update_method(method, %{field: new_value})
      {:ok, %Method{}}

      iex> update_method(method, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_method(%Method{} = method, attrs) do
    method
    |> Method.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a method.

  ## Examples

      iex> delete_method(method)
      {:ok, %Method{}}

      iex> delete_method(method)
      {:error, %Ecto.Changeset{}}

  """
  def delete_method(%Method{} = method) do
    Repo.delete(method)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking method changes.

  ## Examples

      iex> change_method(method)
      %Ecto.Changeset{data: %Method{}}

  """
  def change_method(%Method{} = method, attrs \\ %{}) do
    Method.changeset(method, attrs)
  end
end
