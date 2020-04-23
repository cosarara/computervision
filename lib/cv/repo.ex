defmodule Cv.Repo do
  use Ecto.Repo,
    otp_app: :cv,
    adapter: Ecto.Adapters.Postgres
end
