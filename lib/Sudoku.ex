defmodule SudokuSolver do
  @cell_size 9

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

  defp unsolved?(solvedCells, row, col) do
    !(solvedCells|> Enum.any?(&(&1.row == row and &1.col == col)))
  end

  defp unused(solvedCells, row, col, blk) do
    all_values = 1..@cell_size |> Enum.to_list
    usedVals = solvedCells
      |> Enum.filter(&(&1.row == row or &1.col == col || &1.blk == blk))
      |> Enum.map(&(&1.val))

    all_values -- usedVals
  end

  @doc """
  未入力セルの情報のリストを作成する。
  ## パラメータ
    - solvedCells: すでに入力済みのセルの情報
  """
  defp make_unsolvedCells(solvedCells) do
    for row <- 0..(@cell_size-1), col <- 0..(@cell_size-1), solvedCells |> unsolved?(row, col) do
      with  blk     <- blk(row, col),
            unused  <- solvedCells |> unused(row, col, blk)
      do
        %UnsolvedCell{row: row, col: col, blk: blk, unused: unused}
      end
    end
  end
  
  @doc """
  unused（そのセルに入力可能な数値のリスト） が空の場合、その経路はNG
  """
  defp answer([ %{:unused => []} | _], _, _) do
    nil
  end

  @doc """
  未入力セルのリストが空の場合、それが解。
  """
  defp answer([], initials, results) do
    %Result{initials: initials, results: results}
  end

  @doc """
  未入力セルのリストが空でない場合、unused（そのセルに入力可能な数値のリスト） の数値を一つずつ入力して再起的に解を探索する。
  """
  defp answer([head| _], initials, results) do
    answers = head.unused
      |> Enum.map(&(solve(initials, results ++ [%SolvedCell{row: head.row, col: head.col, blk: blk(head.row, head.col), val: &1}])))
      |> Enum.filter(&(&1))
    if answers |> Enum.count == 1 do
      answers |> Enum.at(0)
    end      
  end

  def solve(initials, results \\ []) do
    initials ++ results
      |> make_unsolvedCells
      |> Enum.sort(&(&1.unused |> Enum.count < &2.unused |> Enum.count))
      |> answer(initials, results)
  end

  def initial(input) do
    for row <- 0..(@cell_size-1), col <- 0..(@cell_size-1), (val = input |> Enum.at(row) |> Enum.at(col)) > 0 do
       %SolvedCell{row: row, col: col, blk: blk(row, col), val: val}
    end
  end

  def print(answer) do
    if answer do
      cells = answer.initials ++ answer.results
      for row <- 0..(@cell_size-1) do
        for col <- 0..(@cell_size-1) do
          cell = cells |> Enum.find(&(&1.row == row and &1.col == col))
          IO.write cell.val
        end
        IO.puts ""
      end
    else
      IO.puts "failed!"
    end
  end

  def main([]) do
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
    end    
end
