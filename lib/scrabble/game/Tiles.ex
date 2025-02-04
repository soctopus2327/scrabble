defmodule Scrabble.Game.Tiles do
  defmodule TileBag do
    defstruct tiles: [], remaining_counts: %{}

    @standard_tiles [
      {" ", 2},
      {"A", 9},
      {"B", 2},
      {"C", 2},
      {"D", 4},
      {"E", 12},
      {"F", 2},
      {"G", 3},
      {"H", 2},
      {"I", 9},
      {"J", 1},
      {"K", 1},
      {"L", 4},
      {"M", 2},
      {"N", 6},
      {"O", 8},
      {"P", 2},
      {"Q", 1},
      {"R", 6},
      {"S", 4},
      {"T", 6},
      {"U", 4},
      {"V", 2},
      {"W", 2},
      {"X", 1},
      {"Y", 2},
      {"Z", 1}
    ]

    def new do
      initial_counts =
        @standard_tiles
        |> Enum.map(fn {letter, count} -> {letter, count} end)
        |> Map.new()

      tiles =
        @standard_tiles
        |> Enum.flat_map(fn {letter, count} ->
          List.duplicate(letter, count)
        end)
        |> Enum.shuffle()

      %__MODULE__{
        tiles: tiles,
        remaining_counts: initial_counts
      }
    end

    def shuffle(%__MODULE__{} = bag) do
      %{bag | tiles: Enum.shuffle(bag.tiles)}
    end

    def shuffle() do
      new() |> shuffle()
    end

    def draw(%__MODULE__{} = bag, count \\ 7) do
      if length(bag.tiles) < count do
        {:error, :insufficient_tiles}
      else
        shuffled_tiles = Enum.shuffle(bag.tiles)
        {drawn_tiles, remaining_tiles} = Enum.split(shuffled_tiles, count)

        new_remaining_counts =
          Enum.reduce(drawn_tiles, bag.remaining_counts, fn tile, counts ->
            Map.update(counts, tile, 0, fn current_count -> current_count - 1 end)
          end)

        new_bag = %{bag |
                    tiles: remaining_tiles,
                    remaining_counts: new_remaining_counts
                  }

        {drawn_tiles, new_bag}
      end
    end

    def get_tiles(%__MODULE__{} = bag, count \\ 7) do
      case draw(bag, count) do
        {:error, _} -> {:error, :insufficient_tiles}
        {drawn_tiles, _new_bag} -> drawn_tiles
      end
    end

    def get_remaining_count(%__MODULE__{} = bag, letter) do
      Map.get(bag.remaining_counts, letter, 0)
    end

    def get_all_remaining_counts(%__MODULE__{} = bag) do
      bag.remaining_counts
    end

    def total_remaining_tiles(%__MODULE__{} = bag) do
      length(bag.tiles)
    end
  end

  @type t :: %{
    player_tiles: list(),
    remaining_tiles: list(),
    initial_tiles: list()
  }

  @initial_tile_count 7

  def init(initial_tiles) do
    player_tiles = Enum.take_random(initial_tiles, @initial_tile_count)
    {:ok, %{
      player_tiles: player_tiles,
      remaining_tiles: initial_tiles -- player_tiles,
      initial_tiles: initial_tiles
    }}
  end

  def remove_tiles(%{player_tiles: player_tiles, remaining_tiles: remaining_tiles, initial_tiles: initial_tiles} = state, tiles_to_remove) do
    {:ok, %{
      player_tiles: player_tiles -- tiles_to_remove,
      remaining_tiles: remaining_tiles ++ tiles_to_remove,
      initial_tiles: initial_tiles
    }}
  end

  def get_player_tiles(%{player_tiles: player_tiles} = _state) do
    player_tiles
  end

  def get_remaining_tiles(%{remaining_tiles: remaining_tiles} = _state) do
    remaining_tiles
  end

  def get_initial_tiles(%{initial_tiles: initial_tiles} = _state) do
    initial_tiles
  end

  def get_missing_tiles_count(%{player_tiles: player_tiles} = _state) do
    @initial_tile_count - length(player_tiles)
  end

  def refill(%{player_tiles: player_tiles, remaining_tiles: remaining_tiles, initial_tiles: initial_tiles} = state) do
    missing_count = get_missing_tiles_count(state)

    if missing_count <= 0 do
      {:ok, state}
    else
      new_tiles = Enum.take_random(remaining_tiles, missing_count)
      new_player_tiles = player_tiles ++ new_tiles
      new_remaining_tiles = remaining_tiles -- new_tiles

      {:ok, %{
        player_tiles: new_player_tiles,
        remaining_tiles: new_remaining_tiles,
        initial_tiles: initial_tiles
      }}
    end
  end
end
