# frozen_string_literal: true

require 'io/console'

module SouthSync
  # mixins
  module CLI
    BANNER = <<~BANNER
        ▄    ▄▄▄     ▄
       ▒▒▒  ▓▒▒▒▓  ▒▒▒▒▒  ▒▒▒▒
       ███   ███   █████  ▒▓█▒
       ▒▒▒   ▒▒▒   ▒▒▒▒▒  ▒▒▒▒
      ─────────────────────────
    BANNER

    def clear_screen
      system('clear')
    end

    def clear_line
      print "\r\e[K"
    end

    def print_banner
      puts BANNER
    end

    def exit_signal
      clear_line
      puts 'Exiting...'
      exit!
    end

    def ask(question, answer = '')
      print "\e[2m#{question}\e[22m\e[1G"

      loop do
        key_pressed = $stdin.getch

        case key_pressed
        when "\u0003" then exit_signal
        when "\u007F" then answer.chop! unless answer.empty?
        when "\r" then return answer unless answer.empty?
        else answer += key_pressed
        end

        clear_line
        print answer
      end
    end
  end
end
