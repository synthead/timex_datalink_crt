# frozen_string_literal: true

require "sdl2"

require "timex_datalink_crt/version"

class TimexDatalinkCrt
  COLOR_BACKGROUND = [0, 0, 0]
  COLOR_DATA = [255, 255, 255]
  COLOR_FONT = [150, 150, 150]

  BYTE_SPREAD_PERCENT = 0.25
  LINE_SPACING_PERCENT = 0.031
  LINE_WIDTH_PERCENT = 0.01

  FONT_CHARACTER_HEIGHT_PERCENT = 0.04
  FONT_CHARACTER_WIDTH_PERCENT = 0.015
  FONT_MARGIN_PERCENT = 0.02

  PACKET_SLEEP_FRAMES = 3

  attr_accessor :packets

  def initialize(packets:)
    @packets = packets
  end

  def draw_packets
    two_bytes_index = 0

    create_window

    two_bytes_from_packets.each do |two_bytes|
      two_bytes.each do |byte_1, byte_2|
        present_on_next_frame do
          return if quit_event?

          draw_byte(byte_1, byte_1_position)
          draw_byte(byte_2, byte_2_position)

          draw_title
          draw_progress(two_bytes_index)

          two_bytes_index += 1
        end
      end
    end
  end

  def draw_byte(byte, byte_position)
    draw_bit(0, byte_position)

    return unless byte

    8.times do |bit_index|
      bit = byte[bit_index]
      bit_position = byte_position + bit_spacing * (bit_index + 1)

      draw_bit(bit, bit_position)
    end
  end

  def draw_bit(state, bit_position)
    return if state.nonzero?

    rect = SDL2::Rect.new
    rect.x = 0
    rect.y = bit_position
    rect.w = window_width
    rect.h = bit_width

    renderer.fill_rect(rect)
  end

  def draw_text(y, text)
    font_render = font.render_solid(text, COLOR_FONT)
    font_texture = renderer.create_texture_from(font_render)
    font_width = text.length * font_character_width
    x = (window_width - font_width) / 2
    font_rect = SDL2::Rect.new(x, y, font_width, font_character_height)

    renderer.copy(font_texture, nil, font_rect)
  end

  def draw_title
    draw_text(font_margin, title_text)
  end

  def draw_progress(two_bytes_index)
    text_percent = "%2.1d" % (two_bytes_index * 100 / two_bytes_count)
    text_progress = "#{text_percent}% complete"
    y = window_height - font_character_height - font_margin

    draw_text(y, text_progress)
  end

  def present_on_next_frame(&block)
    renderer.draw_color = COLOR_BACKGROUND
    renderer.clear

    renderer.draw_color = COLOR_DATA
    block.call if block

    renderer.present
  end

  def quit_event?
    while event = SDL2::Event.poll
      case event
      when SDL2::Event::KeyDown
        return true if event.scancode == SDL2::Key::Scan::ESCAPE
      when SDL2::Event::Quit
        return true
      end
    end

    false
  end

  def packets_with_sleep
    @packet_sleep_bytes ||= packets.map do |packet|
      packet + [nil] * PACKET_SLEEP_FRAMES * 2
    end
  end

  def two_bytes_from_packets
    @two_bytes_from_packets ||= packets_with_sleep.map { |packet| packet.each_slice(2) }
  end

  def two_bytes_count
    @two_bytes_count ||= two_bytes_from_packets.sum(&:count)
  end

  def byte_1_position
    @byte_1_position ||= window_height / 2 - window_height * BYTE_SPREAD_PERCENT - byte_height / 2
  end

  def byte_2_position
    @byte_2_position ||= window_height / 2 + window_height * BYTE_SPREAD_PERCENT - byte_height / 2
  end

  def byte_height
    @byte_height ||= bit_spacing * 8 + bit_width
  end

  def bit_spacing
    @bit_spacing ||= (LINE_SPACING_PERCENT * window_height).to_i
  end

  def bit_width
    @bit_width ||= (LINE_WIDTH_PERCENT * window_height).to_i
  end

  def window_width
    @window_width ||= window.size.first
  end

  def window_height
    @window_height ||= window.size.last
  end

  def font_character_width
    @font_character_width ||= FONT_CHARACTER_WIDTH_PERCENT * window_width
  end

  def font_character_height
    @font_character_height ||= FONT_CHARACTER_HEIGHT_PERCENT * window_height
  end

  def font_margin
    @font_margin ||= FONT_MARGIN_PERCENT * window_height
  end

  def title_text
    @title_text ||= "timex_datalink_crt #{VERSION}"
  end

  def window
    @window ||= SDL2::Window.create(title_text, 0, 0, 0, 0, SDL2::Window::Flags::FULLSCREEN_DESKTOP)
  end

  def renderer
    @renderer ||= window.create_renderer(-1, SDL2::Renderer::Flags::PRESENTVSYNC)
  end

  def font
    @font ||= SDL2::TTF.open("vendor/Inconsolata-Light.ttf", 40)
  end

  def create_window
    SDL2.init(SDL2::INIT_VIDEO | SDL2::INIT_EVENTS)
    SDL2::TTF.init

    renderer

    SDL2::Mouse::Cursor.hide
  end
end
