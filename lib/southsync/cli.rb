# frozen_string_literal: true

module SouthSync
  # view stuff goes here
  module CLI
    def print_header(title, width = 80)
      puts <<~HEADER
           ▄    ▄▄▄     ▄
          ▒▒▒  ▓▒▒▒▓  ▒▒▒▒▒  ▒▒▒▒
          ███   ███   █████  ▒▓█▒
        ┌┐▒▒▒   ▒▒▒   ▒▒▒▒▒  ▒▒▒▒
        ├#{'─' * width}┐
        │ #{title + ' ' * (width - title.size - 2)} │
        ├#{'─' * width}┘
      HEADER
    end

    def remove_ansi(str)
      str.gsub(/\e\[[0-9;]*m/, '').tr('▣', '').strip
    end

    def clear_screen
      system('clear')
    end

    def clear_line
      print "\r\e[K"
    end

    def dimmed_text(str)
      print "\e[2m> #{str}\e[22m\e[1G"
    end

    def green_text(str)
      print "\e[32m#{str}\e[0m"
    end

    def dimmed_bold_text(str)
      puts "\e[1m\e[2m #{str}\e[22m"
    end

    def print_footer(print_help: true)
      puts '│'
      puts '└┘'
      print_help ? dimmed_bold_text("\nj/k: select ╍ enter: choose ╍ q/ctrl+c: quit") : ''
    end

    def print_box(content, width = 25)
      puts <<~BOX
        ├#{'─' * width}╮
        │  #{content + ' ' * (width - content.size - 2)}│
        ├#{'─' * width}╯
      BOX
    end

    def highlight_entry(menu, cursor)
      menu.each_with_index do |entry, i|
        normal = "▢ #{entry[:text]}?"
        highlight = "\e[4m▣ #{entry[:pattern] || entry[:text]}.\e[0m"

        puts "│ #{cursor == i ? highlight : normal}"
      end
    end

    def input_handler(input, cursor)
      exit if ['q', "\u0003"].include?(input)

      cursor += 1 if input == 'j'
      cursor -= 1 if input == 'k'
      cursor
    end

    def display_tree(dirpath)
      clear_screen
      command = "tree #{dirpath}"
      system(command)
    end

    def display(menu, title, cursor = 0)
      loop do
        clear_screen
        print_header(title, 25)
        highlight_entry menu, cursor
        print_footer

        input = $stdin.getch
        cursor = input_handler(input, cursor)
        cursor %= menu.size
        return cursor if input == "\r"
      end
    end

    def loading_indicator(message = 'Checking')
      ['🞕', '🞔', '🞖', '▣'].cycle do |dot|
        clear_line
        print "#{dot} #{message}..."
        sleep rand(0.5..1)
      end
    rescue Interrupt => e
      clear_line
      puts "\rExiting... #{e.message}"
      exit
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
