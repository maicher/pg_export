# frozen_string_literal: true

require 'tty-prompt'

class PgExport
  module Ui
    module Interactive
      class Input
        def select_dump(dumps)
          idx = prompt.select('Select dump to import:') do |menu|
            menu.enum '.'
            dumps.each_with_index do |d, i|
              menu.choice(d.to_s, i)
            end
          end

          dumps[idx]
        end

        def enter_database_name(default = nil)
          puts 'To which database would you like to restore the downloaded dump?'
          prompt.ask('Enter a local database name:') do |q|
            q.required(true)
            q.default(default) if default
          end
        end

        private

        def prompt
          TTY::Prompt.new
        end
      end
    end
  end
end
