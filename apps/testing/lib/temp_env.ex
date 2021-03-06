defmodule Temp.Env do
  defmacro modify(entries) do
    quote do
      setup do
        backup =
          unquote(entries)
          |> Enum.map(fn %{app: app} -> app end)
          |> Enum.uniq()
          |> Enum.reduce([], fn app, acc ->
            Keyword.put(acc, app, Application.get_all_env(app))
          end)

        unquote(entries)
        |> Enum.each(fn entry ->
          case entry do
            %{set: value} ->
              Application.put_env(entry.app, entry.key, value)

            %{update: function} ->
              value = Application.get_env(entry.app, entry.key)
              new_value = function.(value || [])
              Application.put_env(entry.app, entry.key, new_value)

            %{delete: true} ->
              Application.delete_env(entry.app, entry.key)
          end
        end)

        on_exit(fn ->
          Application.put_all_env(backup, persistent: true)
        end)

        :ok
      end
    end
  end
end
