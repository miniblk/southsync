# frozen_string_literal: true

module SouthSync
  # Views
  module CLI
    CTRL_C = "\u0003"
    BACKSPACE = "\u007F"

    DISPLAY_HELP = {
      menu: 'j/k: move up/down ╍ enter: choose ╍ q/ctrl+c: quit ╍ Backspace: back',
      pattern: '[show-title] ╏ [season-number] ╏ [episode-number] ╏ [episode-title]',
      preview: 'enter: to proceed next ╍ b: back ╍ q/ctrl+c: quit',
      any: 'press any key to go back...'
    }.freeze

    LOGO = <<~LOGO.chomp
         ▄    ▄▄▄     ▄
        ▒▒▒  ▓▒▒▒▓  ▒▒▒▒▒  ▒▒▒▒
        ███   ███   █████  ▒▓█▒
      ┌┐▒▒▒   ▒▒▒   ▒▒▒▒▒  ▒▒▒▒
    LOGO

    SQUARES = ['🞕', '🞔', '▢', '▣'].cycle

    # Input stuff
    module Input
      module_function

      def capture_input
        input = $stdin.getch
        send_exit_msg if ['q', CTRL_C].include?(input)

        input
      end

      def send_exit_msg
        Text.clear_line
        puts "Exiting... \e[5m#{['Lame!', '☠'].sample}\e[25m"
        exit
      end

      # == Custom get inputs ==
      def ask_output(answer)
        Text.clear_line
        Text.dimmed '> TIMMAEH! ->  ' if answer.strip.empty?
        print "> #{answer}"
      end

      def ask(question)
        answer = ''
        Text.dimmed question
        loop do
          case key_pressed = capture_input
          when BACKSPACE then answer.chop! unless answer.strip.empty?
          when "\r" then return answer unless answer.strip.empty?
          else answer += key_pressed
          end
          ask_output answer
        end
      end
    end

    # Utilities
    module Text
      module_function

      def clear_line
        print "\r\e[K"
      end

      def dimmed(str, bold: false)
        style = bold ? "\e[1m\e[2m" : "\e[2m"
        print "#{style}#{str}\e[0m\e[1G"
      end

      def green(str, bold: false)
        style = bold ? "\e[1;32m" : "\e[32m"
        puts "#{style}#{str}\e[0m"
      end

      def dimmed_yellow(str, bold: false)
        style = bold ? "\e[1;33m" : "\e[2;33m"
        puts "#{style}#{str}\e[0m"
      end

      def red(str, bold: false)
        style = bold ? "\e[1;91m" : "\e[91m"
        puts "#{style}#{str}\e[39m"
      end
    end

    # UI stuff
    module Display
      module_function

      def clear_screen
        system('clear') || system('cls') || IO.console.clear_screen
      end

      def spin(files_range)
        print "#{files_range.first} video files / #{files_range.last} files" if files_range.first.zero?

        num = 0
        until num.between?(*files_range)
          num += 1
          print "\r\e[K#{SQUARES.next} #{num} video files / #{files_range.last} files"
          sleep rand(0.01..0.07)
        end
      rescue Interrupt => e
        puts e
        Input.send_exit_msg
      end

      # == Template ==
      def print_header(title, width = 40)
        title ||= 'SouthSync'
        puts <<~HEADER
          #{LOGO}
          ├#{'─' * width}┐
          │ #{title + ' ' * (width - title.length - 2)} │
          ├#{'─' * width}┘
        HEADER
      end

      def render_content(header: nil, footer: nil)
        clear_screen
        print_header(header)
        yield if block_given?
        print_footer(footer)
      end

      def print_footer(type)
        puts '│'
        puts "└┘\n\n"
        Text.dimmed(DISPLAY_HELP.fetch(type) { DISPLAY_HELP[:menu] }, bold: true)
      end

      # == Menu ==
      def update_cursor(input, cursor)
        cursor += 1 if input == 'j'
        cursor -= 1 if input == 'k'
        cursor
      end

      def highlight_entry(menu, cursor)
        menu.each_with_index do |entry, i|
          normal = "▢ #{entry[:text]}?"
          highlight = "\e[4m▣ #{entry[:pattern] || entry[:text]}\e[0m"

          puts "│ #{cursor == i ? highlight : normal}"
        end
      end

      def menu(menu:, **opts)
        cursor = 0
        loop do
          render_content(**opts) { highlight_entry menu, cursor }

          input = Input.capture_input
          cursor = update_cursor(input, cursor)
          cursor %= menu.size
          return nil if input == BACKSPACE
          return menu[cursor] if input == "\r"
        end
      end

      def box(str, width = 16)
        puts <<~BOX
          │┌#{'─' * width}╮
          ├┤ #{str + ' ' * (width - str.length - 2)} │
          │└#{'─' * width}╯
        BOX
      end

      def preview(pattern:, lines:, **opts)
        loop do
          render_content(**opts, footer: :preview) do
            box(pattern, pattern.length + 2)
            Text.dimmed "│  #{lines.first}\n"
            Text.green("┠  #{lines.last}", bold: true)
          end
          input = Input.capture_input

          return true if ["\r"].include?(input)
          return false if input == BACKSPACE
        end
      end

      def tree(dir:, files:)
        puts "│  Season #{dir}"
        files.each do |file|
          puts "│ ┝ #{file}"
          sleep rand(0.01..1)
        end
      end

      def error(msg, header)
        str = "#{header[0..33]}..."
        from = msg.index '[!] ['
        loop do
          render_content(header: str, footer: :any) { Text.red "┠ #{msg[from...]}" }

          input = Input.capture_input
          return false if input
        end
      end
    end
  end
end
