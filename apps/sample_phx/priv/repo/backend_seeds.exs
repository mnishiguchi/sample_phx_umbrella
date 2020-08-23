# Script for inserting the backend users so that we can get them to post
# annotations along with our real user conversations.
#
# ## Examples
#
#     cd apps/sample_phx
#     mix run priv/repo/backend_seeds.exs
#     cd -
#
alias SamplePhx.Accounts

{:ok, _} = Accounts.create_user(%{name: "Wolfram", username: "wolfram"})
