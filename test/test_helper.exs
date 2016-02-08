ExUnit.start

Mix.Task.run "ecto.create", ~w(-r ElixirShop.Repo --quiet)
Mix.Task.run "ecto.migrate", ~w(-r ElixirShop.Repo --quiet)
Ecto.Adapters.SQL.begin_test_transaction(ElixirShop.Repo)

{:ok, _} = Application.ensure_all_started(:ex_machina)
