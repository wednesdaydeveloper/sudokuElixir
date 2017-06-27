defmodule SudokuSolver do

  defmodule Cell do
    defstruct row: -1, col: -1, blk: -1
  end

  defmodule UnsolvedCell do
    defstruct row: -1, col: -1, blk: -1, unused: []
  end

  defmodule SolvedCell do
    defstruct row: -1, col: -1, blk: -1, val: -1
  end

  defmodule Result do
    defstruct initials: [], results: []
  end

  defp blk(row, col) do
    [
      [0, 0, 0, 1, 1, 1, 2, 2, 2],
      [0, 0, 0, 1, 1, 1, 2, 2, 2],
      [0, 0, 0, 1, 1, 1, 2, 2, 2],
      [3, 3, 3, 4, 4, 4, 5, 5, 5],
      [3, 3, 3, 4, 4, 4, 5, 5, 5],
      [3, 3, 3, 4, 4, 4, 5, 5, 5],
      [6, 6, 6, 7, 7, 7, 8, 8, 8],
      [6, 6, 6, 7, 7, 7, 8, 8, 8],
      [6, 6, 6, 7, 7, 7, 8, 8, 8],
    ] |> Enum.at(row) |> Enum.at(col)
  end

  defp cellValue(array, row, col) do
    array |> Enum.at(row) |> Enum.at(col)
  end

  defp unsolved?(solvedCells, row, col) do
    !(solvedCells|> Enum.any?(&(&1.row == row and &1.col == col)))
  end

  defp unused(solvedCells, row, col, blk) do
    all_values = 1..9 |> Enum.to_list
    usedVals = solvedCells
      |> Enum.filter(&(&1.row == row or &1.col == col || &1.blk == blk))
      |> Enum.map(&(&1.val))

    all_values -- usedVals
  end

  def solve(initials, results \\ []) do

    solvedCells = initials ++ results

    unsolvedCells = for row <- 0..8, col <- 0..8, solvedCells |> unsolved?(row, col) do
      with  blk = blk(row, col),
            unused = solvedCells |> unused(row, col, blk)
      do
        %UnsolvedCell{
          row: row,
          col: col,
          blk: blk,
          unused: unused,
        }
      end
    end 
      |> Enum.sort(&(&1.unused |> Enum.count < &2.unused |> Enum.count))
    cond do
      unsolvedCells |> Enum.empty? ->
        %Result{initials: initials, results: results}
      unsolvedCells |> Enum.any?(&(&1.unused |> Enum.empty?)) ->
        nil
      true -> 
        [head | _] = unsolvedCells
        answers = head.unused
          |> Enum.map(&(solve(initials, results ++ [%SolvedCell{row: head.row, col: head.col, blk: blk(head.row, head.col), val: &1}])))
          |> Enum.filter(&(&1))
        if answers |> Enum.count == 1 do
          answers |> Enum.at(0)
        end
    end
  end

  def initial(input) do
    for row <- 0..8, col <- 0..8, (val = cellValue(input, row, col)) > 0 do
       %SolvedCell{row: row, col: col, blk: blk(row, col), val: val}
    end
  end

  def print(answer) do
    if answer do
      cells = answer.initials ++ answer.results
      for row <- 0..8 do
        for col <- 0..8 do
          cell = cells |> Enum.find(&(&1.row == row and &1.col == col))
          IO.write cell.val
        end
        IO.puts ""
      end
    end
  end
end

input = [
    [2, 0, 0, 0, 0, 9, 0, 8, 0,],
    [0, 4, 6, 0, 0, 0, 0, 0, 0,],
    [7, 0, 0, 4, 0, 2, 1, 0, 0,],
    [6, 0, 0, 0, 0, 1, 4, 0, 8,],
    [0, 0, 0, 6, 3, 0, 0, 2, 0,],
    [9, 2, 7, 0, 0, 0, 0, 0, 3,],
    [1, 0, 0, 9, 0, 0, 8, 4, 0,],
    [0, 9, 0, 0, 0, 0, 0, 0, 0,],
    [4, 0, 0, 0, 0, 0, 0, 6, 0,],
  ]

input 
  |> SudokuSolver.initial()
  |> SudokuSolver.solve()
  |> SudokuSolver.print()
