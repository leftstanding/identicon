defmodule Identicon do
  @moduledoc """
  Creates a 250x250px identicon based upon the string given
  5x5 grid of 50x50 px squares
  """

  def create_identicon(input) do
    input
    |> hash_input
    |> pick_color
    |> build_grid
    |> filter_odd
    |> build_pixel_map
    |> draw_image
    |> save_image(input)
  end

  def build_pixel_map(%{grid: grid} = struct) do
    # rem(index,5)*50 // div(index, 5)*50
    pixel_map =
      Enum.map(grid, fn {_, index} ->
        horizontal = rem(index, 5) * 50
        vertical = div(index, 5) * 50
        top_left = {horizontal, vertical}
        bottom_right = {horizontal + 50, vertical + 50}

        {top_left, bottom_right}
      end)

    %Identicon.Image{struct | pixel_map: pixel_map}
  end

  def draw_image(%{color: color, pixel_map: pixel_map}) do
    image = :egd.create(250, 250)
    fill = :egd.color(color)

    Enum.each(pixel_map, fn {start, stop} ->
      :egd.filledRectangle(image, start, stop, fill)
    end)

    :egd.render(image)
  end

  def save_image(image, filename) do
    File.write("#{filename}.png", image)
  end

  def generate_points({_, index}) do
    horizontal = rem(index, 5) * 50
    vertical = div(index, 5) * 50
    top_left = {horizontal, vertical}
    bottom_right = {horizontal + 50, vertical + 50}

    {top_left, bottom_right}
  end

  def pick_color(%{hex: [r, g, b | _]} = struct) do
    %Identicon.Image{struct | color: {r, g, b}}
  end

  def build_grid(%{hex: hex} = struct) do
    grid =
      hex
      |> Enum.chunk(3)
      |> IO.inspect()
      |> Enum.map(&mirror_row/1)
      |> List.flatten()
      |> Enum.with_index()

    %Identicon.Image{struct | grid: grid}
  end

  def filter_odd(%{grid: grid} = struct) do
    evengrid =
      grid
      |> Enum.filter(fn {val, _index} -> rem(val, 2) == 0 end)

    %Identicon.Image{struct | grid: evengrid}
  end

  def mirror_row(row) do
    [first, second, third] = row
    [first, second, third, second, first]
  end

  def hash_input(input) do
    hex =
      :crypto.hash(:md5, input)
      |> :binary.bin_to_list()

    %Identicon.Image{hex: hex}
  end
end
