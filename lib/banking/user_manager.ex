defmodule Banking.UserManager do
  @moduledoc """
  The UserManager context.
  """

  import Ecto.Query, warn: false
  alias Banking.Repo

  alias Banking.UserManager.User

  @doc """
  Returns the list of users.

  ## Examples

      iex> list_users()
      [%User{}, ...]

  """
  def list_users do
    Repo.all(User)
  end

  @doc """
  Gets a single user.

  Raises `Ecto.NoResultsError` if the User does not exist.

  ## Examples

      iex> get_user!(123)
      %User{}

      iex> get_user!(456)
      ** (Ecto.NoResultsError)

  """
  def get_user!(id), do: Repo.get!(User, id)

  @doc """
  Creates a user.

  ## Examples

      iex> create_user(%{field: value})
      {:ok, %User{}}

      iex> create_user(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_user(attrs \\ %{}) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a user.

  ## Examples

      iex> update_user(user, %{field: new_value})
      {:ok, %User{}}

      iex> update_user(user, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_user(%User{} = user, attrs) do
    user
    |> User.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a User.

  ## Examples

      iex> delete_user(user)
      {:ok, %User{}}

      iex> delete_user(user)
      {:error, %Ecto.Changeset{}}

  """
  def delete_user(%User{} = user) do
    Repo.delete(user)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user changes.

  ## Examples

      iex> change_user(user)
      %Ecto.Changeset{source: %User{}}

  """
  def change_user(%User{} = user) do
    User.changeset(user, %{})
  end


  def get_user_by_username(username) do
    Repo.get_by(User, username: username)
  end

  def get_user_by_username!(username) do
    Repo.get_by!(User, username: username)
  end

  @doc """
  Authenticate a User.

  ## Examples

      iex> authenticate_user(username, password)
      {:ok, %User{}, token}

      iex> authenticate_user(username, password)
      {:error, reason}

  """
  def authenticate_user(username, password) do
    with %User{} = user <- get_user_by_username(username) do # Get user by username
      # TODO: Verify encripted password
      case password == user.password do # Check if password is correct
        true ->
          {:ok, token, _} = Banking.Guardian.encode_and_sign(user) # Yes, return the access token
          {:ok, token, user} # Return token and user after generate token
        false ->
          {:error, :unauthorized} # No, return an error
      end
    else
      nil ->
        {:error, :unauthorized} # Return error if username not found
    end
  end
end
