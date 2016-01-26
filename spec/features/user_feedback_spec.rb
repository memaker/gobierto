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
    expect(page).to have_content('100.0% POCO')
    expect(page).to have_content('0% APROPIADO')
    expect(page).to have_content('0% MUCHO')

    fill_in 'user_email', with: 'bar@example.com'
    click_button 'Seguir'

    expect(page).to have_content('Comprueba tu correo para confirmar tu acción')

    open_last_email_for 'bar@example.com'
    email = current_email
    expect(email).to have_body_text(/Por favor confirma tu email pinchando en el siguiente enlace/)
    click_email_link_matching /verify/

    fill_in 'user_password', with: 'bar123456'
    fill_in 'user_password_confirmation', with: 'bar123456'
    click_button 'Enviar'

    expect(page).to have_content("Datos actualizados correctamente")
  end

  scenario 'Logged user gives feedback on a budget line', js: true do
    login_as 'foo@example.com', 'foo123456'

    visit '/budget_lines/santander/2015/1/G/economic'
    click_link 'Levanta la mano'
    click_link 'Sí'
    click_link 'Me parece POCO'

    expect(page).to have_content('Gracias por tu opinión')
    expect(page).to have_content('100.0% POCO')
    expect(page).to have_content('0% APROPIADO')
    expect(page).to have_content('0% MUCHO')

    expect(page).to_not have_css('#new_user')
    expect(Answer.last.user_id).to eq(@user.id)
  end

  scenario 'Logged user visits budget line with her feedback', js: true do
    place = INE::Places::Place.find_by_slug 'santander'

    Answer.create answer_text: 'Sí', question_id: 1, user_id: @user.id, place_id: place.id, year: 2015, code: 1, area_name: 'economic', kind: 'G'
    Answer.create answer_text: 'Apropiado', question_id: 2, user_id: @user.id, place_id: place.id, year: 2015, code: 1, area_name: 'economic', kind: 'G'
    Answer.create answer_text: 'Apropiado', question_id: 2, user_id: @user.id, place_id: place.id, year: 2014, code: 1, area_name: 'economic', kind: 'G'

    login_as 'foo@example.com', 'foo123456'

    visit "/budget_lines/#{place.slug}/2015/1/G/economic"
    click_link 'Levanta la mano'

    expect(page).to have_content('Gracias por tu opinión')
    expect(page).to have_content('0% POCO')
    expect(page).to have_content('100.0% APROPIADO')
    expect(page).to have_content('0% MUCHO')

    expect(page).to_not have_css('#new_user')
  end

  scenario 'Logged user visits budget line when replied No', js: true do
    login_as 'foo@example.com', 'foo123456'

    visit '/budget_lines/santander/2015/1/G/economic'
    click_link 'Levanta la mano'
    click_link 'No'

    expect(page).to_not have_content('Puedes solicitar a tu alcalde que amplie la información sobre esta y otras partidas')
    expect(page).to have_content('El 100.0% de personas han respondido que No')

    expect(page).to_not have_css('#new_user')
    expect(Answer.last.user_id).to eq(@user.id)
  end
end
