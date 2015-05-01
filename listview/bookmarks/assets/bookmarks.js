
function enter_values() {
    manual_enter({uri      : ge('inp_uri').value,
                  title    : ge('inp_title').value,
                  desc     : ge('inp_desc').value,
                  tags     : ge('inp_tags').value,
                  data_uri : ge('inp_data_uri').value,
                 })
}
