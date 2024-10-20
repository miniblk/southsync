# frozen_string_literal: true

require 'io/console'

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
      system('cls') || system('clear')
    end

    def clear_line
      print "\r\e[K"
    end

    def print_banner
      puts BANNER
    end

    def prompt(question)
      print "\e[2m#{question}\e[22m\e[1G"

      key_pressed = $stdin.getch
      clear_line
      print key_pressed

      answer = key_pressed + gets.chomp
      answer unless answer.empty?
    rescue Interrupt => e
      puts "Exiting: #{e.message}"
      puts e.backtrace.join("\n")
      exit
    end
  end
end
