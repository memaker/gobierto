require 'rails_helper'

RSpec.feature 'User feedback' do
  before do
    @user = create_user first_name: 'Foo', last_name: 'Wadus'
  end

  scenario 'Anonymous user responds no on a budget line', js: true do
    visit '/budget_lines/santander/2015/1/G/economic'
    click_link 'Levanta la mano'
    click_link 'No'

    expect(page).to have_content('Puedes solicitar a tu alcalde que amplie la información sobre esta y otras partidas')

    fill_in 'user_email', with: 'bar@example.com'
    click_button 'Seguir'

    expect(page).to have_content('Comprueba tu correo para confirmar tu acción')

    open_last_email_for 'bar@example.com'
    email = current_email
    expect(email).to have_body_text(/Por favor confirma tu email pinchando en el siguiente enlace/)
    click_email_link_matching /verify/
  end

  scenario 'Anonymous user gives feedback on a budget line', js: true do
    visit '/budget_lines/santander/2015/1/G/economic'
    click_link 'Levanta la mano'
    click_link 'Sí'
    click_link 'Me parece POCO'

    expect(page).to have_content('Gracias por tu opinión')
    expect(page).to have_content('100% POCO')
    expect(page).to have_content('0% APROPIADO')
    expect(page).to have_content('0% MUCHO')

    fill_in 'user_email', with: 'bar@example.com'
    click_button 'Seguir'

    expect(page).to have_content('Comprueba tu correo para confirmar tu acción')

    open_last_email_for 'bar@example.com'
    email = current_email
    expect(email).to have_body_text(/Por favor confirma tu email pinchando en el siguiente enlace/)
    click_email_link_matching /verify/
  end

  scenario 'Logged user gives feedback on a budget line' do
  end

  scenario 'Logged user visits budget line with her feedback' do
  end
end
