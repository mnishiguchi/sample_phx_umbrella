File.exists?(Path.expand("~/.iex.exs")) && import_file("~/.iex.exs")

alias InfoSys.Cache
alias SamplePhx.{Accounts, Multimedia, Repo}
alias SamplePhx.Accounts.User
alias SamplePhx.Multimedia.{Annotation, Category, Permalink, Video}
alias SamplePhxWeb.Router.Helpers, as: Routes

defmodule Ext do
  @doc """
  A convenience function to update a record.

  ## Examples

      iex> user = Accounts.get_user(2)
      %User{name: "Jose V"}

      iex> Ext.update(user, %{name: "Jose Valim"})
      {:ok, %User{name: "Jose Valim"}

  """
  def update(schema, changes) do
    schema
    |> Ecto.Changeset.change(changes)
    |> Repo.update()
  end
end
