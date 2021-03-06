module HbaseMigrations
  
  class IrreversibleMigration < StandardError#:nodoc:
  end

  class DuplicateMigrationVersionError < StandardError#:nodoc:
    def initialize(version)
      super("Multiple migrations have the version number #{version}")
    end
  end

  class IllegalMigrationNameError < StandardError#:nodoc:
    def initialize(name)
      super("Illegal name for migration file: #{name}\n\t(only lower case letters, numbers, and '_' allowed)")
    end
  end


  module HbaseHelperMethods
    include HbaseCommandConstants

    def big_col(name, options={})
      defaults = { VERSIONS => 100000 }
      options = defaults.merge(options)

      col(name, options)
    end

    def col(name, options={})
      {NAME => name.to_s}.merge(options)
    end
  end

  class Migration
    extend HbaseHelperMethods
    extend HbaseCommands
    include HbaseCommandConstants

    @@verbose = true

    class << self
      attr_accessor :verbose
      attr_accessor :user
      attr_accessor :env
      attr_accessor :server
       
      def up
        migrate(:up)
      end

      def down
        migrate(:down)
      end

      # Execute this migration in the named direction
      def migrate(direction)
        return unless respond_to?(direction)

        case direction
          when :up   then announce "migrating"
          when :down then announce "reverting"
        end

        result = send(direction)

        case direction
          when :up   then announce "migrated "; write
          when :down then announce "reverted "; write
        end

        result
      end

      def write(text="")
        puts(text)
      end

      def announce(message)
        text = "#{@version} #{name}: #{message}"
        length = [0, 75 - text.length].max
        write "== %s %s" % [text, "=" * length]
      end

      def say(message, subitem=false)
        write "#{subitem ? "   ->" : "--"} #{message}"
      end

    end
    
  end

end
