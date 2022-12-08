# frozen_string_literal: true

require "sdl2"

require "timex_datalink_crt/version"

class TimexDatalinkCrt
  COLOR_BACKGROUND = [0, 0, 0]
  COLOR_DATA = [255, 255, 255]

  TICKS_FOR_NEXT_FRAME = 1000 / 60

  BYTE_1_POSITION_PERCENT = 0.1
  BYTE_2_POSITION_PERCENT = 0.6
  LINE_SPACING_PERCENT = 0.03

  attr_accessor :line_position, :last_present

  def initialize
    self.last_present = 0

    SDL2.init(SDL2::INIT_VIDEO)

    renderer

    SDL2::Mouse::Cursor.hide
  end

  def draw_packets(packets)
    packets.each do |bytes|
      bytes.each_slice(2).each do |byte_1, byte_2|
        present_on_next_frame do
          self.line_position = byte_1_position
          draw_byte(byte_1)

          next unless byte_2

          self.line_position = byte_2_position
          draw_byte(byte_2)
        end
      end

      10.times { present_on_next_frame }
    end
  end

  def draw_byte(byte)
    draw_line(0)

    8.times { |index| draw_line(byte[index]) }
  end

  def draw_line(state)
    self.line_position += line_spacing

    return if state.nonzero?

    renderer.draw_line(0, line_position, window_width, line_position)
  end

  def present_on_next_frame(&block)
    while SDL2.get_ticks - last_present < TICKS_FOR_NEXT_FRAME
      SDL2.delay(1)
    end

    renderer.draw_color = COLOR_BACKGROUND
    renderer.clear

    renderer.draw_color = COLOR_DATA
    block.call if block

    renderer.present

    self.last_present = SDL2.get_ticks
  end

  def byte_1_position
    @byte_1_position ||= (BYTE_1_POSITION_PERCENT * window_height).to_i
  end

  def byte_2_position
    @byte_2_position ||= (BYTE_2_POSITION_PERCENT * window_height).to_i
  end

  def line_spacing
    @line_spacing ||= (LINE_SPACING_PERCENT * window_height).to_i
  end

  def window_width
    @window_width ||= window.size.first
  end

  def window_height
    @window_height ||= window.size.last
  end

  def window
    @window ||= SDL2::Window.create("Timex Datalink SDL", 0, 0, 0, 0, SDL2::Window::Flags::FULLSCREEN)
  end

  def renderer
    @renderer ||= window.create_renderer(-1, SDL2::Renderer::Flags::PRESENTVSYNC)
  end
end
