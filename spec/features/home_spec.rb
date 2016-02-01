require 'rails_helper'

RSpec.feature 'Homepage' do
  scenario 'Visit homepage', js: true do
    visit '/'

    expect(page).to have_content('Presupuestos Municipales')
    fill_autocomplete('.pre_home .places_search', page, with: 'madri', select: 'Madrid')

    expect(page).to have_content('Humanes de Madrid')
    expect(page).to have_css("ul#history li", text: 'Humanes de Madrid (2015)')
  end
end
