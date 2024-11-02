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
    BANNER

    def clear_screen
      system('clear')
    end

    def clear_line
      print "\r\e[K"
    end

    def dimmed_text(str)
      print "\e[2m> #{str}\e[22m\e[1G"
    end

    def print_banner
      # add color later || spinner || loading bar
      puts BANNER
    end

    def print_box(content = 'SouthSync', width = 25)
      puts <<~BOX
        ├#{'─' * width}╮
        │  #{content + ' ' * (width - content.size - 2)}│
        ╰#{'─' * width}╯
      BOX
    end

    def exit_signal
      clear_line
      puts 'Exiting...'
      exit!
    end

    def ask_output(answer)
      clear_line
      dimmed_text 'TIMMAEH! 🖝--->  ' if answer.strip.empty?
      print "> #{answer}"
    end

    def ask(question, answer = '')
      dimmed_text question

      loop do
        case key_pressed = $stdin.getch
        when "\u0003" then exit_signal
        when "\u007F" then answer.chop! unless answer.strip.empty?
        when "\r" then return answer unless answer.strip.empty?
        else answer += key_pressed
        end
        ask_output answer
      end
    end
  end
end
