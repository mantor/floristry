module FormTaskHelper
  def call_return_on_form_task(exid, expected_current_nid)
    form_task = Floristry::Web::FormTask.find("#{exid}!#{expected_current_nid}")
    form_task.update_attributes({free_text: 'Testati testato'})
    form_task.return

    form_task
  end
end
