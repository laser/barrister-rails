require "barrister"
require "barrister-intraprocess"
require "barrister-rails/version"
require 'active_attr'

module Barrister

  module Rails

    class Client

      DEFAULT_BARRISTER_TYPES = ['bool', 'int', 'string', 'float']

      class BaseEtherealModel

        include ActiveAttr::Model

        # for building a route
        def to_param
          "#{id}"
        end

        # for determining inflection
        def persisted?
          !id.nil?
        end

      end

      class InterfaceProxy

        attr_reader :name

        def initialize(name, client, fx_metadata)
          @name               = name
          @client             = client
          @fx_metadata        = fx_metadata
        end

        def method_missing(name, *args)
          result = @client.send(@name).send(name, *args)

          if DEFAULT_BARRISTER_TYPES.include?(@fx_metadata[name][:type]) == false
            cast result, @fx_metadata[name][:type], @fx_metadata[name][:is_array]
          else
            result
          end
        end

        def ensure_const(type)
          return Object.const_get(type) if Object.const_defined?(type)

          klass = Class.new(BaseEtherealModel)

          a = attributes_for_type(type).map { |name| "attribute :#{name};" }

          klass.class_eval a.join('')

          Object.send(:const_set, type, klass)

          klass
        end

        def cast(result, type, is_array)
          klass = ensure_const(type)

          if is_array
            result.map { |result| klass.new result }
          else
            klass.new result
          end
        end

        def attributes_for_type(type)
          structs = @client
            .instance_variable_get('@contract')
            .instance_variable_get('@structs')

          all_struct_fields([], structs[type], structs).map { |f| f['name'] }
        end

        def all_struct_fields(arr, struct, structs)
          struct["fields"].each do |f|
            arr << f
          end

          if struct["extends"]
            parent = structs[struct["extends"]]
            if parent
              return all_struct_fields(arr, parent, structs)
            end
          end

          return arr
        end

      end

      def initialize(transport_or_uri_or_handler, json_path=nil)
        if transport_or_uri_or_handler.is_a?(String)
          transport = Barrister::HttpTransport.new(transport_or_uri_or_handler)
        elsif transport_or_uri_or_handler.class.to_s.split('::').first == 'Barrister'
          transport = transport_or_uri_or_handler
        else
          raise 'json_path must be provided if registering a handler directly' unless json_path
          container = Barrister::IntraProcessContainer.new json_path, transport_or_uri_or_handler
          transport = Barrister::IntraProcessTransport.new container
        end

        @client = Barrister::Client.new(transport)
        @custom_types = Hash.new

        interfaces = @client
          .instance_variable_get('@contract')
          .interfaces

        pairs = interfaces
          .map { |iface| iface.functions }
          .flatten
          .map { |fx| [fx.name.to_sym, { type: fx.returns['type'], is_array: fx.returns['is_array'] } ] }

        fx_metadata = Hash[pairs]

        @interface_proxies = interfaces.map { |iface| InterfaceProxy.new iface.name, @client, fx_metadata }
      end

      def method_missing(name, *args)
        name_as_string = name.to_s
        @interface_proxies.find { |iface_proxy| iface_proxy.name == name_as_string }
      end

    end

  end

end
