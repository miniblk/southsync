# frozen_string_literal: true

module SouthSync
  # mixins
  module CLI
    BANNER = <<~BANNER
         ▄    ▄▄▄     ▄
        ▒▒▒  ▓▒▒▒▓  ▒▒▒▒▒  ▒▒▒▒
        ███   ███   █████  ▒▓█▒
      ┌┐▒▒▒   ▒▒▒   ▒▒▒▒▒  ▒▒▒▒
      └─────────────────────────┐
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

    def dimmed_bold_text(str)
      print "\n\e[1m\e[2m #{str}\e[22m"
    end

    def print_help
      dimmed_bold_text 'j/k: select ╍ enter: choose ╍ q/ctrl+c: quit'
    end

    def print_banner
      puts BANNER
    end

    def highlight_entry(menu, cursor)
      menu.each_with_index do |entry, i|
        next if entry[:disabled]

        puts cursor == i ? entry[:highlight] : entry[:normal]
      end
    end

    def input_handler(input, cursor)
      exit if ['q', "\u0003"].include?(input)

      cursor += 1 if input == 'j'
      cursor -= 1 if input == 'k'
      cursor
    end

    def display(menu, cursor = 0)
      loop do
        clear_screen
        print_banner
        highlight_entry menu, cursor
        print_help
        cursor = input_handler($stdin.getch, cursor)
        cursor %= menu.size
      end
    end

    def loading_indicator(message = 'Checking')
      ['🞕', '🞔', '🞖', '▣'].cycle do |dot|
        clear_line
        print "#{dot} #{message}..."
        sleep rand(0.4..0.7)
      end
    rescue Interrupt => e
      clear_line
      puts "\rExiting... #{e.message}"
      exit
    end

    def print_box(content = 'SouthSync', width = 25)
      puts <<~BOX
        ╭#{'─' * width}╮
        │  #{content + ' ' * (width - content.size - 2)}│
        ╰#{'─' * width}╯
      BOX
    end

    def exit_signal
      clear_line
      puts ['Exiting...', 'Oh my God, they killed Kenny!'].sample
      exit
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
