require 'rails_helper'

RSpec.feature 'User signup' do
  scenario 'User signup and account confirmation', js: true do
    visit '/budget_lines/santander/2015/1/G/economic'
    click_link 'Levanta la mano'
    click_link 'No'

    expect(page).to have_content('Puedes solicitar a tu alcalde que amplie la información sobre esta y otras partidas')

    fill_in 'user_email', with: 'bar@example.com'
    click_button 'Seguir'

    expect(page).to have_content('Comprueba tu correo')

    open_last_email_for 'bar@example.com'
    email = current_email
    expect(email).to have_body_text(/Por favor confirma tu email pinchando en el siguiente enlace/)
    click_email_link_matching /verify/

    expect(page).to have_content("Venga, ya casi estamos")

    fill_in 'user_password', with: 'bar123456'
    fill_in 'user_password_confirmation', with: 'bar123456'
    select 'Madrid', from: 'user_place_id'
    click_button 'Enviar'

    expect(page).to have_content("Datos actualizados correctamente")
    expect(page).to_not have_content("Venga, ya casi estamos")
  end
end
