# frozen_string_literal: true

require "sdl2"

require "timex_datalink_crt/version"

class TimexDatalinkCrt
  COLOR_BACKGROUND = [0, 0, 0]
  COLOR_DATA = [255, 255, 255]

  BYTE_1_POSITION_PERCENT = 0.1
  BYTE_2_POSITION_PERCENT = 0.6
  LINE_SPACING_PERCENT = 0.031
  LINE_WIDTH_PERCENT = 0.01

  attr_accessor :line_position

  def initialize
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

    rect = SDL2::Rect.new
    rect.x = 0
    rect.y = line_position
    rect.w = window_width
    rect.h = line_width

    renderer.fill_rect(rect)
  end

  def present_on_next_frame(&block)
    renderer.draw_color = COLOR_BACKGROUND
    renderer.clear

    renderer.draw_color = COLOR_DATA
    block.call if block

    renderer.present
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

  def line_width
    @line_width ||= (LINE_WIDTH_PERCENT * window_height).to_i
  end

  def window_width
    @window_width ||= window.size.first
  end

  def window_height
    @window_height ||= window.size.last
  end

  def window
    @window ||= SDL2::Window.create("Timex Datalink SDL", 0, 0, 0, 0, SDL2::Window::Flags::FULLSCREEN_DESKTOP)
  end

  def renderer
    @renderer ||= window.create_renderer(-1, SDL2::Renderer::Flags::PRESENTVSYNC)
  end
end
