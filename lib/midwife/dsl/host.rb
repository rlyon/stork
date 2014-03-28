module Midwife
  module DSL
    class Host
      attr_reader :name
      attr_accessor :layout
      attr_accessor :template
      attr_accessor :chef
      attr_accessor :pxemac
      attr_accessor :pre_snippets
      attr_accessor :post_snippets
      attr_accessor :interfaces
      attr_accessor :distro
      attr_accessor :timezone
      attr_accessor :firewall
      attr_accessor :password
      attr_accessor :selinux
      attr_accessor :packages

      def initialize(name)
        @name = name
        @layout = "default"
        @template = "default"
        @chef = nil
        @pxemac = nil
        @pre_snippets = []
        @post_snippets = []
        @interfaces = []
        @distro = nil
        # Should be from the config
        @timezone = Timezone.new("America/Los_Angeles")
        @firewall = Firewall.new
        @password = Password.new
        @selinux = "enforcing"
        @packages = default_packages
      end

      def default_packages
        %w{
          @core
          curl
          openssh-clients
          openssh-server
          finger
          pciutils
          yum
          at
          acpid
          vixie-cron
          cronie-noanacron
          crontabs
          logrotate
          ntp
          ntpdate
          tmpwatch
          rsync
          mailx
          which
          wget
          man
        }
      end

      def self.build(collection, name, &block)
        host = new(name)
        delegator = HostDelegator.new(collection, host)
        delegator.instance_eval(&block) if block_given?
        host
      end

      class HostDelegator
        def initialize(collection, obj)
          @collection = collection
          @delegated = obj
        end

        def layout(value, &block)
          if block_given?
            @delegated.layout = Layout.build(value, &block)
          else
            @delegated.layout = @collection.layouts.get(value)
          end
        end

        def template(value)
          @delegated.layout = value
        end

        def chef(value, &block)
          if block_given?
            @delegated.chef = Chef.build(value, &block)
          else
            @delegated.chef = @collection.chefs.get(value)
          end
        end

        def pxemac(value)
          @delegated.pxemac = value
        end

        def pre_snippet(value)
          @delegated.pre_snippets << @collection.snippets.get(value)
        end

        def post_snippet(value)
          @delegated.post_snippets << @collection.snippets.get(value)
        end

        def interface(value, &block)
          @delegated.interfaces << Interface.build(@collection, value, &block)
        end

        def distro(value, &block)
          if block_given?
            @delegated.distro = Distro.build(value, &block)
          else
            @delegated.distro = @collection.distros.get(value)
          end
        end

        def firewall(&block)
          unless block_given?
            raise SyntaxError, "Firewall requires a block"
          end
          @delegated.firewall = Firewall.build(&block)
        end

        def password(&block)
          unless block_given?
            raise SyntaxError, "Password requires a block"
          end
          @delegated.password = Password.build(&block)
        end

        def selinux(value)
          @delegated.selinux = value.to_s
        end
      end

      alias_method :id, :name
    end
  end
end