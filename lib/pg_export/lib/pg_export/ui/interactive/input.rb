# frozen_string_literal: true

require 'tty-prompt'

class PgExport
  module Ui
    module Interactive
      class Input
        def select_dump(dumps)
          prompt = TTY::Prompt.new
          idx = prompt.select('Select dump to import:') do |menu|
            menu.enum '.'
            dumps.each_with_index do |d, i|
              menu.choice(d.name, i)
            end
          end

          dumps[idx]
        end

        def enter_database_name(default = nil)
          prompt = TTY::Prompt.new
          puts 'To which database would you like to restore the downloaded dump?'
          prompt.ask('Enter a local database name:') do |q|
            q.required(true)
            q.default(default) if default
          end
        end
      end
    end
  end
end
