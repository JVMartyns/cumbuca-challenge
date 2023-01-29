defmodule CumbucaWeb.TransactionController do
  use CumbucaWeb, :controller
  # alias Cumbuca.Accounts
  alias Cumbuca.Transactions

  action_fallback CumbucaWeb.FallbackController

  def show(%{assigns: %{account_id: id}} = conn, _attrs) do
    conn
    |> put_status(:ok)
    |> render("show.json", transactions: Transactions.get_all_transactions(id))
  end

  def create(%{assigns: %{account_id: id}} = conn, %{"cpf" => cpf, "value" => value}) do
    preloads = [:sender_account, :receiver_account]

    with {:ok, builded} <- Transactions.build_transaction(id, cpf, value),
         {:ok, transaction} <- Transactions.insert_transaction(builded),
         {:ok, preloaded} <- Transactions.preload_assoc(transaction, preloads) do
      conn
      |> put_status(:created)
      |> render("show.json", transaction: preloaded)
    end
  end

  def process_transaction(conn, %{"transaction_id" => transaction_id}) do
    with {:ok, transaction} <- Transactions.process_transaction(transaction_id) do
      conn
      |> put_status(:ok)
      |> render("show.json", transaction: transaction)
    end
  end
end