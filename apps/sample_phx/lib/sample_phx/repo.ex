defmodule SamplePhx.Repo do
  use Ecto.Repo,
    otp_app: :sample_phx,
    adapter: Ecto.Adapters.Postgres
end
