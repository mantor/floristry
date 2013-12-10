module RuoteTrail

  class ExpressionFactory

    def self.create(h, era = :present)  # TODO CLEANUPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPP

      # If not a valid Ruote expression, default to participant.
      #
      #name = h.participant_name.camelize
      name = h['participant_name'].camelize
      if is_a_ruote_expression?(name)

        RuoteTrail::const_get(name).new(h, era)
      else

        RuoteTrail::Participant.new(h, era)
      end
    end

    protected

    # Test if a valid class and is a subclass of Expression
    #
    # TODO - low priority - could this be cleaner? avoid exceptions?
    #
    def self.is_a_ruote_expression?(name)

      RuoteTrail.const_get(name) < RuoteTrail::Expression
      true

    rescue NameError
      false

    end
  end
end