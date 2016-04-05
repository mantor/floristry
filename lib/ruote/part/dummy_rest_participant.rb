# This belongs with the Workflow Engine and will be migrated once decoupled with Rails.
#

# WebParticipant (ActiveRecord) backend participant
#
class DummyRestParticipant
  include Ruote::LocalParticipant

  def initialize(options)

    @options = options
  end

  def do_not_thread() true end

  def on_workitem

    push( participant_name, workitem )

    # proceed if forget
  end

  def on_cancel

    delete(participant_name, fei)
  end

  protected

  def push(backend_part_name, workitem)

    web_part_class(backend_part_name).create(workitem.to_h)
  end

  def delete(backend_part_name, fei)

    fei.h['subid'] = NO_SUBID
    web_part_class(backend_part_name).find(fei.sid).destroy
  end

  def web_part_class(backend_part_name)

    name = backend_part_name.sub(ActiveTrail::WEB_PARTICIPANT_REGEX, '').camelize
    ActiveTrail::WebParticipant.const_get(name)
  end
end