defmodule Prever.Wildfire.Csv do
  def load(file_path, opts \\ []) do
    file_path
    |> File.stream!()
    |> CSV.decode!(opts)
    |> to_maps()
  end

  defp to_maps(stream) do
    # Pull the first row as the header
    [header | rows] = Enum.to_list(stream)

    Enum.map(rows, fn row ->
      Enum.zip(header, row)
      |> Enum.into(%{})
    end)
  end
end
