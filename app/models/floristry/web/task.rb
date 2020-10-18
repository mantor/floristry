module Floristry::Web

  # This is the frontend for web_tasks.
  # The corresponding backend are models inheriting from Floristry::ActiveRecord::Base
  #
  class Task < Floristry::Task

    PREFIX = 'web'
    REGEX = /^#{PREFIX}/

    def update_attributes(new_attributes, options={})

      instance.update_attributes(new_attributes, options)
    end

    def errors

      instance.errors
    end

    # TODO this is a workaround to mix the actual tasks
    def instance

      return @instance unless @instance.nil?

      begin
        @instance = klass.find(@id)
      rescue ActiveRecord::RecordNotFound
        @instance = klass.new
      end

      @instance.fei = @fei
      @instance.era = @era
      @instance
    end

    protected

    def klass

      k = @name.sub(PREFIX, '').camelize
      Floristry::Web.const_get k
    end
  end
end